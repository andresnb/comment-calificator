# frozen_string_literal: true

# Has all the Score Scale data
module ScoreScale
  def score_scale
    [
      dev_skills_scale,
      user_stories_scale,
      critical_user_stories_scale,
      non_critical_user_stories_scale
    ]
  end

  def dev_skills_scale
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

  def user_stories_scale
    [
      'User Stories',
      'Not applied',
      'Applied but with glitches',
      'Correctly applied'
    ]
  end

  def critical_user_stories_scale
    [
      'Critical User Stories',
      'Not applied',
      'Applied but not working',
      'Applied but with glitches',
      'Correctly applied'
    ]
  end

  def non_critical_user_stories_scale
    [
      'Non Critical Features',
      'Not applied',
      'Applied'
    ]
  end
end
