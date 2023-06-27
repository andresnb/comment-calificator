require_relative 'evaluation'

class Student
  attr_accessor :name, :aproved, :evaluation

  def initialize(name: '', evaluation: Evaluation.new, aproved: false)
    @name = name
    @aproved = aproved
  end
end
