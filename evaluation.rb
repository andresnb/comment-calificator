
require_relative 'grade'
require_relative 'cell'

class Evaluation
  attr_accessor :dev_skills, :user_stories, :optional, :total

  def initialize(total = Grade.new, dev_skills = Grade.new, user_stories = Grade.new, optional = Grade.new)
    @total = total
    @dev_skills = dev_skills
    @user_stories = user_stories
    @optional = optional
  end

  def assign_totals(matrixes:, keys:, sheet:)
    ranges_cells = []
    matrixes.each do |matrix|
      ranges_cells << Cell.separate_matrix(matrix, sheet)
    end

    matrix_array = []
    ranges_cells.each do |range_cells|
      matrix_array << range_cells[0].create_matrix_array(range_cells[1])
    end
    matrix_array = join_arrays(matrix_array)
    total_header = get_header_data(matrix_array, keys)
    total_details = get_details_data(matrix_array, keys)

    Grade.new(description: total_header["description"],
                      max_score: total_header["max_score"],
                      score: total_header["score"],
                      details: total_details)
  end

  def join_arrays(matrix)
    return if matrix.length == 1
    
    first_array = matrix.shift
    second_array = matrix.shift

    first_array.each_with_index do |f, i|
      f << second_array[i][0]
    end

    matrix.unshift(first_array)
    join_arrays(matrix)

    first_array
  end

  def get_header_data(array, keys)
    object = {}

    keys.each_with_index do |key, i|
      object[key] = array[0][i]
    end
    
    object
  end

  def get_details_data(array, keys)
    details = []
    details_array = array.drop(1)

    details_array.each_with_index do |_detail, i|
      object = {}
      keys.each_with_index do |key, j|
        object[key] = details_array[i][j]
      end
      details << object
    end

    details
  end

end
