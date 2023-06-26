class Grade
  attr_accessor :score, :details

  def initialize(max_score = 0, score = 0, details = [])
    @max_score = max_score
    @score = score
    @details = details
  end
end
