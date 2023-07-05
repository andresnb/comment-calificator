require 'roo'
require 'google_drive'
require 'googleauth'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'


def main()
  # Load the credentials JSON file
  credentials_file = 'credentials.json'
  credentials = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(credentials_file),
    scope: Google::Apis::DriveV3::AUTH_DRIVE
  )

  session = GoogleDrive::Session.from_credentials(credentials)
  session.files.each do |file|
    puts file.title
  end

  
  raise "stop right now, thankyou very much."
  # xlsx = Roo::Spreadsheet.open(file)
  evaluations = xlsx.sheet('Evaluations')

  keys = %w[description max_score score]
  total_students = prompt_user('Input Total of Students/Groups cell', default:'E44') {|input| input.match?(/\A[A-Z]+\d+\z/)}
  totals_matrix = prompt_user('Input Totals Interval in the spreadsheet:', default:'C7:D10') {|input| input.match?(/[A-Z]+\d+:[A-Z]+\d+/)}
  dev_skills_matrix = prompt_user('Input Dev Skills Interval in the spreadsheet:', default:'B14:D18') {|input| input.match?(/[A-Z]+\d+:[A-Z]+\d+/)}
  user_stories_matrix = prompt_user('Input User Stories Interval in the spreadsheet:', default:'B20:D37') {|input| input.match?(/[A-Z]+\d+:[A-Z]+\d+/)}
  optional_matrix = prompt_user('Input Bonus Stories Interval in the spreadsheet:', default:'B39:D40') {|input| input.match?(/[A-Z]+\d+:[A-Z]+\d+/)}
  student_starter_column = prompt_user('Input the column where the 1st Score appears:', default:'E') {|input| input.match?(/^[A-Za-z]+$/)}
  (1..get_cell_value(total_students, evaluations)).each do |student_index|
    step = student_index - 1
    student_column = Cell.letter_to_integer(student_starter_column) + step
    title = evaluations.cell('A', 1)
    evaluation = Evaluation.new(title)
    student = Student.new
    student.name = evaluations.cell(Cell.integer_to_letter(student_column), 4)
    totals_student = get_student_range(Cell.integer_to_letter(student_column), totals_matrix)
    dev_skills_student = get_student_range(Cell.integer_to_letter(student_column), dev_skills_matrix)
    user_stories_student = get_student_range(Cell.integer_to_letter(student_column), user_stories_matrix)
    optional_student = get_student_range(Cell.integer_to_letter(student_column), optional_matrix)

    print "Evaluating #{student.name}\n"

    evaluation.total = evaluation.assign_totals(matrixes: [totals_matrix, totals_student], keys: keys,
                                                sheet: evaluations)
    puts "Calculating Totals [#{totals_matrix}]..."
    evaluation.dev_skills = evaluation.assign_totals(matrixes: [dev_skills_matrix, dev_skills_student], keys: keys,
                                                     sheet: evaluations)
    puts "Calculating Dev Skills [#{dev_skills_matrix}]..."
    evaluation.user_stories = evaluation.assign_totals(matrixes: [user_stories_matrix, user_stories_student],
                                                       keys: keys, sheet: evaluations)
    puts "Calculating User Stories [#{user_stories_matrix}]..."
    evaluation.optional = evaluation.assign_totals(matrixes: [optional_matrix, optional_student], keys: keys,
                                                   sheet: evaluations)
    puts "Calculating Bonus Stories [#{optional_matrix}]..."

    evaluation.student = student
    evaluation.student.aproved = evaluation.aproved?
    puts "Evaluation #{evaluation.aproved_text.downcase}!"

    puts 'Creating text file...'
    create_evaluation_file(evaluation, student_index)
  end
end

def prompt_user(prompt, error_message = "Input Error!", default:"")
  input = ''
  prompt += " (Leave empty for default value: #{default})" unless default.nil?
  loop do
    print "#{prompt}\n>"
    input = gets.chomp.upcase.strip
    input = default unless input.nil?
    break if yield(input)

    puts error_message
  end

  input
end

def get_student_range(column, interval)
  top_row, bottom_row = interval.scan(/\d+/).map(&:to_i)
  "#{column}#{top_row}:#{column}#{bottom_row}"
end

def get_cell_value(cell, sheet)
  col, row = cell.scan(/\d+|[A-Za-z]+/)
  p col, row
  sheet.cell(col, row.to_i)
end

def create_evaluation_file(evaluation, n)
  file_path = "output/#{format('%02d',
                               n)}-#{evaluation.student.name.gsub(' ', '-')}-#{evaluation.title.gsub(' ', '-')}.txt"
  File.open(file_path, 'w') do |file|
    file.puts evaluation.write_comment
  end

  puts "File '#{file_path}' created.\n\n"
end

file = ARGV.shift
ARGV.clear

main()
