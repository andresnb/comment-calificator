# Handles the table formatting according to GitHub table formats
module TableFormat
  def remove_element(array, index)
    a = array.dup
    a.delete_at(index)
    a
  end

  def break_line(this_many = 1)
    br = ''
    this_many.times do
      br += "\n"
    end

    @text += br
  end

  def bold(text)
    "**#{text}**"
  end

  def line
    @text += "--\n"
  end

  def table_pattern(number)
    pattern = ' -- |'
    result = pattern * number
    result[-1] = "\n"

    result
  end

  def add_table_bars(array)
    "|#{array.join('|')}|\n"
  end

  def draw_table(header:, details:, remove_index: nil)
    table = ''
    table += add_table_bars(header)
    table += table_pattern(header.length)

    details.each do |detail|
      detail = remove_element(detail, remove_index) unless remove_index.nil?
      table += add_table_bars(detail)
    end

    table.chop
  end
end
