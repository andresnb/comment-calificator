require_relative 'grade'
require_relative 'cell'
require_relative 'student'

class Evaluation
  attr_accessor :dev_skills, :user_stories, :optional, :total,
                :title, :description, :scale, :aproval_percent,
                :notes, :aproval_score, :explanation, :student

  def initialize(title = '')
    @total = Grade.new
    @dev_skills = Grade.new
    @user_stories = Grade.new
    @optional = Grade.new
    @title = title
    @description = load_description
    @scale = load_scale
    @aproval_percent = 0.6
    @aproval_score = 0
    @aproved_text = 'NOT APROVED'
    @notes = []
    @explanation = ''
    @text = ''
    @student = Student.new
  end

  def aproved?
    @aproval_score = @total.max_score * @aproval_percent
    @explanation = load_explanation
    @aproved_text = 'APROVED' if @total.score >= @aproval_score

    @total.score >= @aproval_score
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
    # total_details = get_details_data(matrix_array, keys)
    matrix_array.shift

    Grade.new(description: total_header['description'],
              max_score: total_header['max_score'],
              score: total_header['score'],
              details: matrix_array)
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

  def write_comment
    @text += @title
    break_line
    line
    @text += @description
    break_line
    draw_table(header: [bold('SKILL'), '0', '1', '2', '3', '4', '5'],
               details: @scale)
    break_line(2)
    @text += explanation
    break_line(2)
    @text += "#{bold('STUDENT:')} #{@student.name.upcase}"
    break_line
    @text += "#{bold('RESULT:')} #{@aproved_text.upcase}"
    break_line(2)
    draw_table(header: ['Total', @total.score],
               details: @total.details, remove: 2)
    break_line(2)
    @text += "#{bold('DETAILS')}"
    break_line
    draw_table(header: [@dev_skills.description, 'Max Score', 'Your Score'],
               details: @dev_skills.details.push(['TOTAL', [@dev_skills.max_score, @dev_skills.score]]))
    break_line(2)
    draw_table(header: [@user_stories.description, 'Max Score', 'Your Score'],
               details: @user_stories.details.push(['TOTAL',
                                                    [@user_stories.max_score, @user_stories.score]]))
    break_line(2)
    draw_table(header: [@optional.description, 'Max Score', 'Your Score'],
               details: @optional.details.push(['TOTAL', [@optional.max_score, @optional.score]]))
    break_line(2)
    @text += "#{bold('NOTES')}"
    break_line(2)
    @text += print_notes(get_notes)
  end

  private

  def print_notes(notes)
    note_txt = ''
    notes.each do |note|
      note_txt += "- #{note}\n"
    end

    @text += note_txt
  end

  def get_notes
    puts 'Give the students some insights, write a note!'
    puts '>'
    input = gets(":q\n").chomp(":q\n")
    input.split("\n")
  end

  def load_description
    "This rubic breaks the #{@title} into several key objectives. Each one of the goals is scored with the scales listed in the table below."
  end

  def load_explanation
    "To pass, the student needs at least #{@aproval_score} (**total of #{@total.max_score} points + #{@optional.max_score} bonus points**)"
  end

  def load_scale
    [[
      'Dev Skills',
      'Not applied',
      'Barely applied',
      'Somewhat applied',
      'Decently applied',
      'Mostly applied',
      'Correctly applied'
    ],
     [
       'User Stories',
       'Not applied',
       'Applied but with glitches',
       'Correctly applied'
     ],
     [
       'Critical User Stories',
       'Not applied',
       'Applied but not working',
       'Applied but with glitches',
       'Correctly applied'
     ],
     [
       'Non Critical Features',
       'Not applied',
       'Applied'
     ]]
  end

  def draw_table(header:, details:, remove: 0)
    table = ''
    table += add_table_bars(header)
    table += table_pattern(header.length)

    details.each do |detail|
      detail = remove_element(detail, remove) if remove.positive?
      table += add_table_bars(detail)
    end

    @text += table.chop
  end

  def add_table_bars(array)
    "|#{array.join('|')}|\n"
  end

  def table_pattern(number)
    pattern = ' -- |'
    result = pattern * number
    result[-1] = "\n"

    result
  end

  def last_element?(array, element)
    array.index(element) == array.length - 1
  end

  def remove_element(array, index)
    a = array.dup
    a.delete_at(index)
    a
  end

  def break_line(n = 1)
    br = ''
    n.times do
      br += "\n"
    end

    @text += br
  end

  def bold(text)
    "**#{text}**"
  end

  def line
    @text += "--\n"
  end
end
