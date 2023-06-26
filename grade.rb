class Grade
  attr_accessor :score, :details

  def initialize(score = 0, details = [])
    @score = score
    @details = details
  end
end
