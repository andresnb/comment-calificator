# frozen_string_literal: true

# Contains the grades, description, max score and details as an array
class Grade
  attr_accessor :score, :details, :description, :max_score

  def initialize(description: '', max_score: 0, score: 0, details: [])
    @description = description
    @max_score = max_score
    @score = score
    @details = details
  end
end
