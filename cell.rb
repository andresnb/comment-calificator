
require 'roo'

class Cell
  attr_accessor :row, :column, :sheet

  def initialize(column = 1, row = 1, sheet)
    if sheet.is_a?(Cell)
      cell = sheet
      @column = cell.column
      @row = cell.row
      @sheet = cell.sheet
    else
      @row = row
      @column = column
      @sheet = sheet
    end
  end

  def self.value(column, row, sheet)
    return sheet.cell(column, row) if column.is_a?(String)

    sheet.cell(row, column)
  end

  def self.copy(cell)
    cell.dup
  end

  def value
    return @sheet.cell(@column, @row) if @column.is_a?(String)

    @sheet.cell(@row, @column)
  end

  def up
    @row -= 1 unless @row == 1
    self
  end

  def down(step = 1)
    @row += 1 * step
    self
  end

  def right(step = 1)
    if @column.is_a?(String)
      n = letter_to_integer(@column)
      n += 1 * step
      @column = integer_to_letter(n)
    else
      @column += 1 * step
    end
    self
  end

  def left(step = 1)
    if @column.is_a?(String)
      n = letter_to_integer(@column)
      n -= 1 * step unless n < 1
      @column = integer_to_letter(n)
    else
      @column -= 1 * step unless @column < 1
    end
    self
  end

  def same?(other_cell)
    @column == other_cell.column && @row == other_cell.row
  end

  def self.get_matrix_values(matrixes:, rows: 1)
    values = []
    rows.times do |_|
      matrixes.each do |matrix|
        c = 0
        columns = matrix.columns
        object = {}
        object[matrix.key[c]] << matrix.cell.value
        while columns > 1
          matrix.cell.right
          c += 1
          columns -= 1
          object[matrix.key[c]] << matrix.cell.value
        end
        matrix.cell.down
        matrix.cell.left(c)
      end
      values << object
    end

    values
  end

  private

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
