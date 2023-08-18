# frozen_string_literal: true

# Methods required to handle spreadsheet movement
module SheetReader
  def create_matrix(left_cell, right_cell, step, mode = 'r')
    inner = insert_cell_values(left_cell, right_cell, step, mode)

    left_cell.left(step)
    left_cell.down
    right_cell.down

    inner
  end
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
                 description: prompt,
                 max_score: max }

    return cell.value
  end

  score = prompt_user("#{prompt} [#{max}]") do |input|
    input.to_i >= 0 && input.to_i <= max
  end

  @sheet[cell.coordinate] = score
end

def unwritable?(prompt, _mode)
  unwritable = ['total', 'dev skills', 'user stories', 'bonus stories']

  unwritable.include?(prompt.downcase)
end
