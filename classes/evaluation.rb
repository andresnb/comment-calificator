# frozen_string_literal: true

require_relative 'grade'
require_relative 'cell'
require_relative 'student'
require_relative '../helpers/user_prompt'
require_relative '../helpers/comment_writer'

# Handles all the evaluation data including dev skills, dev stories and bonus stories
class Evaluation
  include UserPrompt
  include CommetWriter

  attr_accessor :dev_skills, :user_stories, :optional, :total,
                :title, :description, :scale, :aproval_percent,
                :student, :sheet

  def initialize(sheet)
    @total = Grade.new
    @dev_skills = Grade.new
    @user_stories = Grade.new
    @optional = Grade.new
    @title = title
    @aproval_percent = 0.7
    @text = ''
    @student = Student.new
    @memory = []
    @sheet = sheet
  end

  def aproved?
    @total.score >= aproval_score
  end

  def aproval_score
    @total.max_score * @aproval_percent
  end

  def evaluate_totals(data_cell, student_cell, mode)
    @total = create_table(data_cell, student_cell, mode: mode)
    data_cell.movement_sequence({ down: 3, left: 1 })
    student_cell.down(3)

    @dev_skills = create_table(data_cell, student_cell, 2, mode: mode)
    data_cell.down
    student_cell.down

    @user_stories = create_table(data_cell, student_cell, 2, mode: mode)
    data_cell.down
    student_cell.down

    @optional = create_table(data_cell, student_cell, 2, mode: mode)
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
    inner = insert_cell_values(left_cell, right_cell, step, mode)

    left_cell.left(step)
    left_cell.down
    right_cell.down

    inner
  end

  def insert_cell_values(left_cell, right_cell, step, mode)
    array = []
    array << left_cell.value
    prompt = array.last
    left_cell.right(step)
    array << left_cell.value
    max = array.last
    array << ask_for_value(right_cell, prompt, max, mode)

    array
  end

  def ask_for_value(cell, prompt, max, mode)
    if unwritable?(prompt, mode) || mode.downcase == 'r'
      @memory << { coordinate: cell.coordinate,
                   description: prompt }

      return cell.value
    end

    score = prompt_user(prompt) do |input|
      input.to_i.positive? && input.to_i <= max
    end

    @sheet[cell.coordinate] = score
  end

  def unwritable?(prompt, _mode)
    unwritable = ['total', 'dev skills', 'user stories', 'bonus stories']

    unwritable.include?(prompt.downcase)
  end

  def write_comment
    write_title
    write_description
    write_skill_scale
    write_explanation
    write_student_name
    write_result
    write_totals
    write_details
    write_notes

    @text
  end
end
