require_relative 'student'
require_relative 'evaluation'
require_relative 'cell'
require_relative 'helpers/user_prompt'
require_relative 'sessions/google'

class App
  include UserPrompt

  def initialize
    @mode = 'r'
  end

  def start
    drive = Google.new('credentials.json')

    cohort, mod, week = prompt_file_data
    file = drive.get_file(cohort, mod, week)
    sheet = file.worksheet_by_title('Evaluations')

    description_cell_start = 'C7'
    student_cell_start = 'E4'
    total_students = Cell.new('E44', sheet).value

    description_cell = Cell.new(description_cell_start, sheet)
    student_cell = Cell.new(student_cell_start, sheet)

    evaluation_loop(total_students, description_cell, student_cell)
  end

  def evaluation_loop(total_students, description_cell, student_cell)
    (1..total_students).each do |student_index|
      student_evaluation(student_index, description_cell, student_cell)

      description_cell = Cell.new(description_cell_start, sheet)
      student_cell = Cell.new(student_cell_start, sheet)
      student_cell.right(student_index)
    end
  end

  def student_evaluation(student_index, description_cell, student_cell)
    evaluation = evaluation_initial_values(sheet)

    evaluation.evaluate_totals(description_cell, student_cell, @mode)

    evaluation.student.aproved = evaluation.aproved?
    puts "Evaluation #{evaluation.aproved_text.downcase}!"

    evaluation.sheet.save

    puts 'Creating text file...'
    create_evaluation_file(evaluation, student_index)
  end

  def evaluation_initial_values(sheet)
    evaluation = Evaluation.new(sheet)
    evaluation.title = Cell.new('A1', sheet).value
    student = Student.new
    student.name = student_cell.value
    student_cell.down(3)
    evaluation.student = student

    print "Evaluating #{student.name}\n"

    evaluation
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

  def make_list(array)
    str = ''
    array.each_with_index do |e, i|
      str += "#{i + 1}. #{e}\n"
    end

    str.chop
  end

  def create_evaluation_file(evaluation, student_number)
    file_path = filename_format(evaluation, student_number)
    File.open(file_path, 'w') do |file|
      file.puts evaluation.write_comment
    end

    puts "File '#{file_path}' created.\n\n"
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
