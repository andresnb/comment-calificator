require 'roo'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'

APROVED_PERCENT = 0.6

def main
  xlsx = Roo::Spreadsheet.open('input/M04-W4-IE-Doable-JS.xlsx')
  evaluations = xlsx.sheet('Evaluations')

  keys = %w[description max_score score]
  total_students = evaluations.cell('C', 42)
  totals_matrix = 'A5:B8'
  dev_skills_matrix = 'A11:B15'
  user_stories_matrix = 'A17:B29'
  optional_matrix = 'A31:B33'
  student_starter_column = Cell.letter_to_integer('C')

  (1..total_students).each do |student_index|
    step = student_index - 1
    student_column = student_starter_column + step
    evaluation = Evaluation.new('Javascript Individual Evaluation')
    student = Student.new

    student.name = evaluations.cell(Cell.integer_to_letter(student_column), 10)
    totals_student = get_student_range(Cell.integer_to_letter(student_column), totals_matrix)
    dev_skills_student = get_student_range(Cell.integer_to_letter(student_column), dev_skills_matrix)
    user_stories_student = get_student_range(Cell.integer_to_letter(student_column), user_stories_matrix)
    optional_student = get_student_range(Cell.integer_to_letter(student_column), optional_matrix)

    evaluation.total = evaluation.assign_totals(matrixes: [totals_matrix, totals_student], keys: keys,
                                                sheet: evaluations)
    evaluation.dev_skills = evaluation.assign_totals(matrixes: [dev_skills_matrix, dev_skills_student], keys: keys,
                                                     sheet: evaluations)
    evaluation.user_stories = evaluation.assign_totals(matrixes: [user_stories_matrix, user_stories_student],
                                                       keys: keys, sheet: evaluations)
    evaluation.optional = evaluation.assign_totals(matrixes: [optional_matrix, optional_student], keys: keys,
                                                   sheet: evaluations)

    evaluation.student = student
    evaluation.student.aproved = evaluation.aproved?

    create_evaluation_file(evaluation, student_index)
  end
end

def get_student_range(column, interval)
  top_row, bottom_row = interval.scan(/\d+/).map(&:to_i)
  "#{column}#{top_row}:#{column}#{bottom_row}"
end

def get_cell_value(cell, sheet)
  col, row = cell.scan(/\d+|[A-Za-z]+/) if cell.is_a?(String)
  row, col = cell.values_at(:row, :column) if cell.is_a?(Hash)

  sheet.cell(row, col.to_i)
end

def create_evaluation_file(evaluation, n)
  file_path = "output/#{format('%02d',
                               n)}-#{evaluation.student.name.gsub(' ', '-')}-#{evaluation.title.gsub(' ', '-')}.txt"
  File.open(file_path, 'w') do |file|
    file.puts evaluation.write_comment
  end

  puts "File '#{file_path}' created.\n"
end

main
