require_relative 'grade'
require_relative 'cell'

class Evaluation
  attr_accessor :dev_skills, :user_stories, :optional, :total,
                :title, :description, :scale, :aproval_percent,
                :notes

  def initialize(title)
    @total = total
    @dev_skills = dev_skills
    @user_stories = user_stories
    @optional = optional
    @title = title
    @description = load_description
    @scale = load_scale
    @aproval_percent = 0.6
    @notes = []
  end

  def aproved?
    @total.score >= @total.max_score * @aproval_percent
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

    Grade.new(description: total_header['description'],
              max_score: total_header['max_score'],
              score: total_header['score'],
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

  private

  def load_description
    "This rubic breaks the #{@title} into several key objectives. Each one of the goals is scored with the scales listed in the table below."
  end

  def load_scale
    {
      skills: [
        {
          name: 'Dev Skills',
          metric: {
            '0' => 'Not applied',
            '1' => 'Barely applied',
            '2' => 'Somewhat applied',
            '3' => 'Decently applied',
            '4' => 'Mostly applied',
            '5' => 'Correctly applied'
          }
        },
        {
          name: 'User Stories',
          metric: {
            '0' => 'Not applied',
            '1' => 'Applied but with glitches',
            '2' => 'Correctly applied'
          }
        },
        {
          name: 'Critical User Stories',
          metric: {
            '0' => 'Not applied',
            '1' => 'Applied but not working',
            '2' => 'Applied but with glitches',
            '3' => 'Correctly applied'
          }
        },
        {
          name: 'Non Critical Features',
          metric: {
            '0' => 'Not applied',
            '1' => 'Applied'
          }
        }
      ]
    }
  end
end
