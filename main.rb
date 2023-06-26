
require 'roo'
require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'

APROVED_PERCENT = 0.6

def main
  

  xlsx = Roo::Spreadsheet.open('input/W4-IE-CLIvia-Generator.xlsx')
  evaluations =  xlsx.sheet('Evaluaciones')

  total_students = evaluations.cell('C', 46)
  details_cell = Cell.new('A', 5, evaluations)
  score_cell = Cell.new('C', 5, evaluations)

  max_eval = Evaluation.new

  (1..total_students).each do |_|
    evaluation = Evaluation.new

    evaluation.assign_totals(detail_cell_init: details_cell, score_cell_init: score_cell, rows_range: "5-8")
    break
    evaluation.assign_dev_skills(detail_cell_init: details_cell, score_cell_init: score_cell, rows_range: "12-16")
    evaluation.assign_user_stories(detail_cell_init: details_cell, score_cell_init: score_cell, rows_range: "19-31")
    evaluation.assign_optionals(detail_cell_init: details_cell, score_cell_init: score_cell, rows_range: "34-37")

  end
end

def get_cell_value(cell, sheet)
  col, row = cell.scan(/\d+|[A-Za-z]+/) if cell.is_a?(String)
  row, col = cell.values_at(:row, :column) if cell.is_a?(Hash)

  sheet.cell(row, col.to_i)
end

main
