# frozen_string_literal: true

require_relative 'grade'
require_relative 'cell'
require_relative 'student'
require_relative '../helpers/user_prompt'
require_relative '../helpers/comment_writer'
require_relative '../helpers/sheet_reader'

# Handles all the evaluation data including dev skills, dev stories and bonus stories
class Evaluation
  include UserPrompt
  include CommetWriter
  include SheetReader

  attr_accessor :dev_skills, :user_stories, :optional, :total,
                :title, :memory, :aproval_percent, :student, :sheet

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

  def dump_memory
    @total.details = []
    @memory.each do |data|
      cell_value = Cell.new(data[:coordinate], @sheet).value
      case data[:description]
      when 'Total'
        @total.score = cell_value
      else
        @total.details << [data[:description], data[:max_score], cell_value] if total.details.length < 3
      end
    end
  end

  def write_comment(mode)
    write_title
    write_description
    write_skill_scale
    write_explanation
    write_student_name
    write_result
    write_totals
    write_details
    write_notes if mode.match?(/^w$/i)

    @text
  end
end
