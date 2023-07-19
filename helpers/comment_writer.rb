# frozen_string_literal: true

require_relative 'table_format'
require_relative 'score_scale'

# Methods required to handle writing the evaluation
module CommetWriter
  include TableFormat
  include ScoreScale

  def write_title
    @text += @title
    break_line
    line
  end

  def write_description
    @text += load_description
    break_line
  end

  def write_skill_scale
    draw_table(header: [bold('SKILL'), '0', '1', '2', '3', '4', '5'],
               details: score_scale)
    break_line(2)
  end

  def write_explanation
    @text += load_explanation
    break_line(2)
  end

  def write_student_name
    @text += "#{bold('STUDENT:')} #{@student.name.upcase}"
    break_line
  end

  def write_result
    @student.aproved_text = @student.aproved ? 'APROVED' : 'NOT APROVED'
    @text += "#{bold('RESULT:')} #{@student.aproved_text}"
    break_line(2)
  end

  def write_totals
    draw_table(header: ['Total', @total.score],
               details: @total.details, remove_index: 1)
    break_line(2)
  end

  def write_details
    @text += bold('DETAILS').to_s
    break_line
    write_details_table(@dev_skills)
    break_line(2)
    write_details_table(@user_stories)
    break_line(2)
    write_details_table(@optional)
    break_line(2)
  end

  def write_details_table(grade)
    header = [grade.description, 'Max Score', 'Your Score']
    details = grade.details.push(['TOTAL', grade.max_score, grade.score])
    @text += draw_table(header: header, details: details)
  end

  def write_notes
    print_notes(ask_fot_notes)
  end

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
    'This rubic breaks the project into several key objectives.
    Each one of the goals is scored with the scales listed in the table below.'
  end

  def load_explanation
    "To pass, the student needs at least #{aproval_score.floor.to_i}
    (**total of #{@total.max_score} points + #{@optional.max_score} bonus points**)"
  end
end
