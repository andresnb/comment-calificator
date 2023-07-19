require_relative 'grade'
require_relative 'cell'
require_relative 'student'
require_relative 'helpers/user_prompt'

class Evaluation
  include UserPrompt

  attr_accessor :dev_skills, :user_stories, :optional, :total,
                :title, :description, :scale, :aproval_percent,
                :notes, :aproval_score, :explanation, :student,
                :aproved_text, :sheet

  def initialize(sheet)
    @total = Grade.new
    @dev_skills = Grade.new
    @user_stories = Grade.new
    @optional = Grade.new
    @title = title
    @description = load_description
    @scale = load_scale
    @aproval_percent = 0.7
    @aproval_score = 0
    @aproved_text = 'NOT APROVED'
    @notes = []
    @explanation = ''
    @text = ''
    @student = Student.new
    @memory = []
    @sheet = sheet
  end

  def aproved?
    @aproval_score = @total.max_score * @aproval_percent
    @explanation = load_explanation
    @aproved_text = 'APROVED' if @total.score >= @aproval_score

    @total.score >= @aproval_score
  end

  def evaluate_totals(data_cell, student_cell, mode)
    @total = create_table(data_cell, student_cell, mode: mode)
    cell_movement_sequence(data_cell, { down: 3, left: 1 })
    student_cell.down(3)

    @dev_skills = create_table(data_cell, student_cell, 2, mode: mode)
    data_cell.down
    student_cell.down

    @user_stories = create_table(data_cell, student_cell, 2, mode: mode)
    data_cell.down
    student_cell.down

    @optional = create_table(data_cell, student_cell, 2, mode: mode)
  end

  def cell_movement_sequence(cell, sequence)
    sequence.each do |direction, steps|
      move_cell(cell, direction, steps)
    end
  end

  def move_cell(cell, direction, steps)
    case direction
    when :up
      cell.up(steps)
    when :down
      cell.down(steps)
    when :left
      cell.left(steps)
    when :right
      cell.right(steps)
    end
  end

  def create_table(data_cell, student_cell, sidestep = 1, mode: 'r')
    header = create_matrix(data_cell, student_cell, sidestep)
    details = []
    details << create_matrix(data_cell, student_cell, sidestep, mode) until data_cell.value.nil?

    Grade.new(
      description: header[0],
      max_score: header[1],
      score: header[2],
      details: details
    )
  end

  def create_matrix(left_cell, right_cell, step, mode = 'r')
    inner = []

    inner << left_cell.value
    prompt = inner.last
    left_cell.right(step)
    inner << left_cell.value
    max = inner.last
    inner << ask_for_value(right_cell, prompt, max, mode)

    left_cell.left(step)
    left_cell.down
    right_cell.down

    inner
  end

  def ask_for_value(cell, prompt, max, mode)
    if mode.downcase == 'r' || prompt.downcase == 'total' || prompt.downcase == 'dev skills' || prompt.downcase == 'user stories' || prompt.downcase == 'bonus stories'
      @memory << { coordinate: cell.coordinate,
                   description: prompt }

      return cell.value
    end

    score = prompt_user(prompt) do |input|
      input.to_i.positive? && input.to_i <= max
    end

    @sheet[cell.coordinate] = score
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
               details: @total.details, remove_index: 1)
    break_line(2)
    @text += bold('DETAILS').to_s
    break_line
    draw_table(header: [@dev_skills.description, 'Max Score', 'Your Score'],
               details: @dev_skills.details.push(['TOTAL', @dev_skills.max_score, @dev_skills.score]))
    break_line(2)
    draw_table(header: [@user_stories.description, 'Max Score', 'Your Score'],
               details: @user_stories.details.push(['TOTAL',
                                                    @user_stories.max_score, @user_stories.score]))
    break_line(2)
    draw_table(header: [@optional.description, 'Max Score', 'Your Score'],
               details: @optional.details.push(['TOTAL', @optional.max_score, @optional.score]))

    break_line(2)
    print_notes(ask_fot_notes)

    @text
  end

  private

  def print_notes(notes)
    note_txt = ''
    notes.each do |note|
      note_txt += "- #{note}\n"
    end

    return if notes.empty?

    @text += bold('NOTES').to_s
    break_line(2)
    @text += note_txt
  end

  def ask_fot_notes
    puts "Give #{@student.name} some insights, write some notes!"
    puts '>'
    input = gets(":q\n").chomp(":q\n")
    input.split("\n")
  end

  def load_description
    'This rubic breaks the project into several key objectives. Each one of the goals is scored with the scales listed in the table below.'
  end

  def load_explanation
    "To pass, the student needs at least #{@aproval_score.floor.to_i} (**total of #{@total.max_score} points + #{@optional.max_score} bonus points**)"
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

  def draw_table(header:, details:, remove_index: nil)
    table = ''
    table += add_table_bars(header)
    table += table_pattern(header.length)

    details.each do |detail|
      detail = remove_element(detail, remove_index) unless remove_index.nil?
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