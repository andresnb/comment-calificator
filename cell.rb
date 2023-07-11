require 'roo'
require 'google_drive'

class Cell
  attr_accessor :coordinate, :row, :column, :sheet

  def initialize(coordinate, sheet)
    @coordinate = coordinate
    @column, @row = separate_coordinate(coordinate)
    @sheet = sheet
  end

  def self.value(column, row, sheet)
    return sheet.cell(column, row) if column.is_a?(String)

    sheet.cell(row, column)
  end

  def self.copy(cell)
    cell.dup
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

  def same?(other_cell)
    @column == other_cell.column && @row == other_cell.row
  end

  def create_matrix_array(final_cell)
    outer_matrix = []
    inner_matrix = []
    col_move = column_difference(@column, final_cell.column) + 1
    row_move = final_cell.row - @row + 1
    row_move.times do |_|
      col_move.times do |_|
        v = value
        v = v.floor.to_i if v.is_a?(Float)
        inner_matrix << v unless v.nil?
        right
      end
      outer_matrix << inner_matrix
      inner_matrix = []
      left(col_move)
      down
    end
    outer_matrix
  end

  private

  def column_difference(col1, col2)
    col1 = letter_to_integer(col1) if col1.is_a?(String)
    col2 = letter_to_integer(col2) if col2.is_a?(String)

    col2 - col1
  end

  def current_cell
    return "#{@column}-#{@row}" if @column.is_a?(String)

    "#{integer_to_letter(@column)}-#{@row}"
  end

  def integer_to_letter(n)
    result = []
    quotient, remainder = (n - 1).divmod(26)

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
