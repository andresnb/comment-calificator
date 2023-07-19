class Student
  attr_accessor :name, :aproved

  def initialize(name: '', aproved: false)
    @name = name
    @aproved = aproved
  end
end
