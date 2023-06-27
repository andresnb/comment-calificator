require 'roo'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'

APROVED_PERCENT = 0.6

def main
  xlsx = Roo::Spreadsheet.open('input/W4-IE-CLIvia-Generator.xlsx')
  evaluations = xlsx.sheet('Evaluaciones')

  keys = %w[description max_score score]
  total_students = evaluations.cell('C', 46)
  totals_matrix = 'A5:B8'
  dev_skills_matrix = 'A12:B16'
  user_stories_matrix = 'A18:B31'
  optional_matrix = 'A33:B37'
  student_starter_column = Cell.letter_to_integer('C')

  (1..total_students).each do |student|
    step = student - 1
    student_column = student_starter_column + step
    evaluation = Evaluation.new('Ruby Individual Evaluation')
    student = Student.new

    student.name = evaluations.cell(Cell.integer_to_letter(student_column), 11)
    totals_student = "#{Cell.integer_to_letter(student_column)}5:#{Cell.integer_to_letter(student_column)}8"
    dev_skills_student = "#{Cell.integer_to_letter(student_column)}12:#{Cell.integer_to_letter(student_column)}16"
    user_stories_student = "#{Cell.integer_to_letter(student_column)}18:#{Cell.integer_to_letter(student_column)}31"
    optional_student = "#{Cell.integer_to_letter(student_column)}33:#{Cell.integer_to_letter(student_column)}37"

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

    puts evaluation.write_comment
  end
end

def get_cell_value(cell, sheet)
  col, row = cell.scan(/\d+|[A-Za-z]+/) if cell.is_a?(String)
  row, col = cell.values_at(:row, :column) if cell.is_a?(Hash)

  sheet.cell(row, col.to_i)
end

main
