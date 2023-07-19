# Has all the Score Scale data
module ScoreScale
  def score_scale
    [
      dev_skills,
      user_stories,
      critical_user_stories,
      non_critical_user_stories
    ]
  end

  def dev_skills
    [
      'Dev Skills',
      'Not applied',
      'Barely applied',
      'Somewhat applied',
      'Decently applied',
      'Mostly applied',
      'Correctly applied'
    ]
  end

  def user_stories
    [
      'User Stories',
      'Not applied',
      'Applied but with glitches',
      'Correctly applied'
    ]
  end

  def critical_user_stories
    [
      'Critical User Stories',
      'Not applied',
      'Applied but not working',
      'Applied but with glitches',
      'Correctly applied'
    ]
  end

  def non_critical_user_stories
    [
      'Non Critical Features',
      'Not applied',
      'Applied'
    ]
  end
end
