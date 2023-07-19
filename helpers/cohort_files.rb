# frozen_string_literal: true

# Has all the documentations of the evaluations files in the google drive folders
module CohortFiles
  def modulos
    {
      'Ruby' => ruby,
      'HTML_&_CSS' => html_css,
      'Rails' => rails,
      'Javascript' => javascript,
      'React' => react
    }
  end

  def ruby
    {
      'folder' => 'Module_01-Ruby',
      'projects' => {
        'Week_1' => { name: 'CalenCLI', type: 'EP' },
        'Week_2' => { name: 'Pokemon_Ruby', type: 'EP' },
        'Week_3' => { name: 'CLIn_Boards', type: 'EP' },
        'Week_4' => { name: 'CLIvia_Generator', type: 'IP' }
      }
    }
  end

  def html_css
    {
      'folder' => 'Module_02-HTML&CSS',
      'projects' => {
        'Week_1' => { name: 'Codeable_UI', type: 'IP' },
        'Week_2' => { name: 'Codeable_UI', type: 'IP' }
      }
    }
  end

  def rails
    {
      'folder' => 'Module_03-Rails',
      'projects' => {
        'Week_1' => { name: 'Insights', type: 'EP' },
        'Week_2' => { name: 'Music_Store', type: 'EP' },
        'Week_3' => { name: 'Somesplash', type: 'EP' },
        'Week_4' => { name: 'Critics_RC', type: 'EP' },
        'Week_5' => { name: 'Tweetable', type: 'IP' }
      }
    }
  end

  def javascript
    {
      'folder' => 'Module_04-Javascript',
      'projects' => {
        'Week_1' => { name: 'Easter_Eggs', type: 'EP' },
        'Week_2' => { name: 'Keepable_JS', type: 'EP' },
        'Week_3' => { name: 'JS_Contactable', type: 'EP' },
        'Week_4' => { name: 'JS_Doable', type: 'IP' }
      }
    }
  end

  def react
    {
      'folder' => 'Module_05-React',
      'projects' => {
        'Week_1' => { name: 'Expensable_Calculator', type: 'EP' },
        'Week_2' => { name: 'Expensable_Calculator_Add_On', type: 'EP' },
        'Week_3' => { name: 'Github_Stats', type: 'EP' },
        'Week_4' => { name: 'Eatable', type: 'EP' },
        'Week_5' => { name: 'Eatable_2', type: 'IP' }
      }
    }
  end
end
