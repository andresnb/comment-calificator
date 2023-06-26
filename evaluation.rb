
require_relative 'grade'
require_relative 'cell'

class Evaluation
  attr_accessor :dev_skills, :user_stories, :optional, :total

  def initialize
    @total = Grade.new
    @dev_skills = Grade.new
    @user_stories = Grade.new
    @optional = Grade.new
    
  end

  def assign_totals(detail_cell_init:, score_cell_init:, rows_range:)
    object_detail = {
      cell: detail_cell_init,
      columns: 2,
      keys: ["description", "max_score"]
    }
    object_score = {
      cell: score_cell_init,
      columns: 1,
      keys: ["score"]
    }
    @total.details = Cell.get_matrix_values(matrixes: [object_detail, object_score], rows: get_rows_range(rows_range))
  end


  def assign_dev_skills(detail_cell_init:, score_cell_init:, rows_range:)
  end

  def assign_user_stories(detail_cell_init:, score_cell_init:, rows_range:)
  end

  def assign_optionals(detail_cell_init:, score_cell_init:, rows_range:)
  end

  private

  def get_rows_range(string)
    init, final = string.split("-").map(&:to_i)
    final - init + 1
  end

end
