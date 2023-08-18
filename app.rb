# frozen_string_literal: true

require_relative 'classes/student'
require_relative 'classes/evaluation'
require_relative 'classes/cell'
require_relative 'helpers/user_prompt'
require_relative 'helpers/evaluation_handler'
require_relative 'sessions/google'

# Main Structure for App to work
class App
  include UserPrompt
  include EvaluationHandler

  def initialize
    @mode = 'r'
    @description_cell_start = ''
    @student_cell_start = ''
  end

  def start
    drive = GoogleSession.new('credentials.json')

    cohort, mod, week = prompt_file_data
    file = drive.get_file(cohort, mod, week)
    sheet = file.worksheet_by_title('Evaluations')

    @description_cell_start = 'C7'
    @student_cell_start = 'E4'
    total_students = Cell.new('D4', sheet).value

    description_cell = Cell.new(@description_cell_start, sheet)
    student_cell = Cell.new(@student_cell_start, sheet)

    evaluation_loop(total_students, description_cell, student_cell, sheet)
  end

  def prompt_file_data
    cohort, mod, week = validaiton_loop

    @mode = prompt_user('Use reading or writing mode? [R/W]', default: 'y') do |input|
      input.match?(/^(reading|writing)$/i) || input.match?(/^[rw]$/i) || input.match?(/^(read|write)$/i)
    end

    [cohort, mod, week]
  end

  def validaiton_loop
    confirmed = false

    until confirmed
      cohort, mod, week = catch_cohort_mod_week
      confirmed = confirm_data([cohort, mod, week])
    end

    [cohort, mod, week]
  end

  def catch_cohort_mod_week
    week = 'Week '
    cohort = select_options(%w[C-10 C-11], 'Which Cohort are you evaluating?')
    mod = select_options(['Ruby', 'HTML & CSS', 'Rails', 'Javascript', 'React'], 'Which Module are you evaluating?')
    week += prompt_user('What is the week of the module?') do |input|
      input.match?(/^[1-5]$/)
    end

    [cohort, mod, week]
  end

  def confirm_data(data_array)
    confirmation = prompt_user("Is this selection ok?[Y/N]\n #{data_array.join(', ')}", default: 'y') do |input|
      input.match?(/^(yes|no)$/i) || input.match?(/^[yn]$/i)
    end

    return true if confirmation[0].upcase == 'Y'

    false
  end

  def filename_format(evaluation, number)
    "output/#{student_number(number)}-#{student_name(evaluation)}-#{evaluation_title(evaluation)}.txt"
  end

  def student_number(number)
    format('%02d', number)
  end

  def student_name(evaluation)
    evaluation.student.name.gsub(' ', '-')
  end

  def evaluation_title(evaluation)
    evaluation.title.gsub(' ', '')
  end
end
