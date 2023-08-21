# frozen_string_literal: true

# Methods required to handle spreadsheet movement
module EvaluationHandler
  def evaluation_loop(total_students, description_cell, student_cell, sheet)
    (1..total_students).each do |student_index|
      student_evaluation(student_index, description_cell, student_cell, sheet)

      description_cell = Cell.new(@description_cell_start, sheet)
      student_cell = Cell.new(@student_cell_start, sheet)
      student_cell.right(student_index)
    end
  end

  def student_evaluation(student_index, description_cell, student_cell, sheet)
    evaluation = evaluation_initialize(student_cell, sheet)

    return false unless evaluation

    evaluation.evaluate_totals(description_cell, student_cell, @mode)

    evaluation.sheet.save
    evaluation.sheet.reload
    evaluation.dump_memory if @mode == 'w' || @mode == 'W'

    evaluation.student.load_aproval_text(evaluation.aproved?)
    puts "Evaluation #{evaluation.student.aproved_text.downcase}!"

    puts 'Creating text file...'
    create_evaluation_file(evaluation, student_index)
  end

  def evaluation_initialize(student_cell, sheet)
    evaluation = Evaluation.new(sheet)
    evaluation.title = Cell.new('A1', sheet).value
    student = Student.new
    student.name = student_cell.value
    student_cell.down(3)
    evaluation.student = student

    input = prompt_user("Evaluating #{student.name}\n (S to skip)")

    return evaluation if input.nil? || !input.match?(/^[sS]$/)

    false
  end

  def create_evaluation_file(evaluation, student_number)
    file_path = filename_format(evaluation, student_number)
    File.open(file_path, 'w') do |file|
      file.puts evaluation.write_comment
    end

    puts "File '#{file_path}' created.\n\n"
  end
end
