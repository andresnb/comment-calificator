require 'roo'
require 'google_drive'
require 'googleauth'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'

def main
  credentials_file = 'credentials.json'
  session = GoogleDrive::Session.from_service_account_key(credentials_file)
  confirmed = false

  until confirmed
    week = 'Week '
    cohort = select_options(%w[C-10 C-11], 'Which Cohort are you evaluating?')
    mod = select_options(['Ruby', 'HTML & CSS', 'Rails', 'Javascript', 'React'], 'Which Module are you evaluating?')
    week += prompt_user('What is the week of the module?') do |input|
      input.match?(/^[1-5]$/)
    end

    confirmed = confirm_data([cohort, mod, week])
  end

  file = get_file(cohort, mod, week, session)

  sheet = file.worksheet_by_title('Evaluations')

  description_cell = Cell.new('C7', sheet)
  student_cell = Cell.new('E4', sheet)
  total_students = Cell.new('E44', sheet).value

  keys = %w[description max_score score]

  (1..total_students).each do |student_index|
    evaluation = Evaluation.new(Cell.new('A1', sheet).value)
    student = Student.new
    student.name = student_cell.value
    student_cell.down

    print "Evaluating #{student.name}\n"

    evaluation.grade_student(description_cell, student_cell)

    evaluation.student = student
    evaluation.student.aproved = evaluation.aproved?
    puts "Evaluation #{evaluation.aproved_text.downcase}!"

    puts 'Creating text file...'
    create_evaluation_file(evaluation, student_index)
  end
end

def get_file(cohort, mod, week, session)
  week = week.gsub(' ', '_')
  mod = mod.gsub(' ', '_')

  modulos = {
    'Ruby' => {
      'folder' => 'Module_01-Ruby',
      'projects' => {
        'Week_1' => { name: 'CalenCLI', type: 'EP' },
        'Week_2' => { name: 'Pokemon_Ruby', type: 'EP' },
        'Week_3' => { name: 'CLIn_Boards', type: 'EP' },
        'Week_4' => { name: 'CLIvia_Generator', type: 'IP' }
      }
    },
    'HTML_&_CSS' => {
      'folder' => 'Module_02-HTML&CSS',
      'projects' => {
        'Week_1' => { name: 'Codeable_UI', type: 'IP' },
        'Week_2' => { name: 'Codeable_UI', type: 'IP' }
      }
    },
    'Rails' => {
      'folder' => 'Module_03-Rails',
      'projects' => {
        'Week_1' => { name: 'Insights', type: 'EP' },
        'Week_2' => { name: 'Music_Store', type: 'EP' },
        'Week_3' => { name: 'Somesplash', type: 'EP' },
        'Week_4' => { name: 'Critics_RC', type: 'EP' },
        'Week_5' => { name: 'Tweetable', type: 'IP' }
      }
    },
    'Javascript' => {
      'folder' => 'Module_04-Javascript',
      'projects' => {
        'Week_1' => { name: 'Easter_Eggs', type: 'EP' },
        'Week_2' => { name: 'Keepable_JS', type: 'EP' },
        'Week_3' => { name: 'JS_Contactable', type: 'EP' },
        'Week_4' => { name: 'JS_Doable', type: 'IP' }
      }
    },
    'React' => {
      'folder' => 'Module_05-React',
      'projects' => {
        'Week_1' => { name: 'Expensable_Calculator', type: 'EP' },
        'Week_2' => { name: 'Expensable_Calculator_Add_On', type: 'EP' },
        'Week_3' => { name: 'Github_Stats', type: 'EP' },
        'Week_4' => { name: 'Eatable', type: 'EP' },
        'Week_5' => { name: 'Eatable_2', type: 'IP' }
      }
    }
  }
  cohort_folder = session.file_by_title(cohort)
  module_folder = cohort_folder.file_by_title(modulos[mod]['folder'])

  module_folder.file_by_title("#{week}-#{modulos[mod]['projects'][week][:type]}-#{modulos[mod]['projects'][week][:name]}")
end

def confirm_data(data_array)
  confirmation = prompt_user("Is this selection ok?[Y/N]\n #{data_array.join(', ')}") do |input|
    input.match?(/^(yes|no)$/i) || input.match?(/^[yn]$/i)
  end

  return true if confirmation[0].upcase == 'Y'

  false
end

def select_options(options, promt)
  option = prompt_user("#{promt}\n#{make_list(options)}") do |input|
    element = input.to_i
    input.match?(/^\d$/) & element.between?(1, options.size)
  end

  options[option.to_i - 1]
end

def make_list(array)
  str = ''
  array.each_with_index do |e, i|
    str += "#{i + 1}. #{e}\n"
  end

  str.chop
end

def prompt_user(prompt, error_message = 'Input Error!', default: nil)
  input = ''
  prompt += " (Leave empty for default value: #{default})" unless default.nil?
  loop do
    print "#{prompt}\n>"
    input = gets.chomp.upcase.strip
    input = default if input.nil?
    break if yield(input)

    puts error_message
  end

  input
end

def create_evaluation_file(evaluation, n)
  file_path = "output/#{format('%02d',
                               n)}-#{evaluation.student.name.gsub(' ', '-')}-#{evaluation.title.gsub(' ', '-')}.txt"
  File.open(file_path, 'w') do |file|
    file.puts evaluation.write_comment
  end

  puts "File '#{file_path}' created.\n\n"
end

main
