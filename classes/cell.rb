# frozen_string_literal: true

require 'google_drive'

# Creates a cell the user can opperate between the Google Drive Worksheet
class Cell
  attr_accessor :coordinate, :row, :column, :sheet

  def initialize(coordinate, sheet)
    @coordinate = coordinate
    @column, @row = separate_coordinate(coordinate)
    @sheet = sheet
  end

  def movement_sequence(sequence)
    sequence.each do |direction, steps|
      move_cell(direction, steps)
    end
  end

  def move_cell(direction, steps)
    case direction
    when :up
      up(steps)
    when :down
      down(steps)
    when :left
      left(steps)
    when :right
      right(steps)
    end
  end

  def separate_matrix(matrix, sheet)
    top_left, bottom_right = matrix.split(':')
    r, c = separate_coordinate(top_left)
    top_left_cell = Cell.new(r, c, sheet)
    r, c = separate_coordinate(bottom_right)
    bottom_right_cell = Cell.new(r, c, sheet)

    [top_left_cell, bottom_right_cell]
  end

  def separate_coordinate(coordinate)
    column = coordinate[/[A-Z]+/]
    row = coordinate[/\d+/].to_i
    [column, row]
  end

  def value
    value = sheet["#{@column}#{@row}"]
    return value.to_i if value.match?(/^\d+$/)
    return nil if value == ''

    value
  end

  def up(step = 1)
    @row -= 1 * step unless @row == 1
    update_coordinate

    self
  end

  def down(step = 1)
    @row += 1 * step
    update_coordinate

    self
  end

  def right(step = 1)
    n = letter_to_integer(@column)
    n += 1 * step
    @column = integer_to_letter(n)
    update_coordinate

    self
  end

  def left(step = 1)
    n = letter_to_integer(@column)
    n -= 1 * step unless n < 1
    @column = integer_to_letter(n)
    update_coordinate

    self
  end

  def update_coordinate
    @coordinate = "#{@column}#{@row}"
  end

  private

  def integer_to_letter(int)
    result = []
    quotient, remainder = (int - 1).divmod(26)

    while quotient >= 0
      result.unshift(('A'.ord + remainder).chr)
      quotient, remainder = (quotient - 1).divmod(26)
    end

    result.join
  end

  def letter_to_integer(string)
    string.upcase!
    result = 0
    base = 26

    string.each_char do |char|
      digit_value = char.ord - 'A'.ord + 1
      result = (result * base) + digit_value
    end

    result
  end
end
