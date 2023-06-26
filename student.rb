
require_relative 'grade'

class Student
  attr_accessor :name, :aproved, :grade

  def initialize(name: '', grade: 0, aproved: false)
    @name = name
    @aproved = aproved
    @grade = grade
  end
end
