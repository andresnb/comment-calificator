# frozen_string_literal: true

# Contains Student Data
class Student
  attr_accessor :name, :aproved, :aproved_text

  def initialize(name: '', aproved: false)
    @name = name
    @aproved = aproved
    @aproved_text = 'NOT APROVED'
  end

  def load_aproval_text(aproved)
    @aproved_text = 'APROVED' if aproved
  end
end
