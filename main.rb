
require 'roo'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'

APROVED_PERCENT = 0.6

def main
  

  xlsx = Roo::Spreadsheet.open('input/W4-IE-CLIvia-Generator.xlsx')
  evaluations = xlsx.sheet('Evaluaciones')

  keys = ["description", "max_score", "score"]
  total_students = evaluations.cell('C', 46)
  totals_matrix = "A5:B8"
  dev_skills_matrix = "A12:B16"
  user_stories_matrix = "A18:B31"
  optional_matrix = "A33:B37"

  (1..total_students).each do |_|
    
    evaluation = Evaluation.new
    totals_student = "C5:C8"
    dev_skills_student = "C12:C16"
    user_stories_student = "C18:C31"
    optional_student = "C33:C37"

    totals = evaluation.assign_totals(matrixes: [totals_matrix, totals_student], keys: keys, sheet: evaluations)
    dev_skills = evaluation.assign_totals(matrixes: [dev_skills_matrix, dev_skills_student], keys: keys, sheet: evaluations)
    user_stories = evaluation.assign_totals(matrixes: [user_stories_matrix, user_stories_student], keys: keys, sheet: evaluations)
    optional = evaluation.assign_totals(matrixes: [optional_matrix, optional_student], keys: keys, sheet: evaluations)

    break

  end
end

def get_cell_value(cell, sheet)
  col, row = cell.scan(/\d+|[A-Za-z]+/) if cell.is_a?(String)
  row, col = cell.values_at(:row, :column) if cell.is_a?(Hash)

  sheet.cell(row, col.to_i)
end

main
