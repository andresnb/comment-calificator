module UserPrompt
  def prompt_user(prompt, error_message: 'Input Error!', default: nil)
    input = ''
    loop do
      print "#{prompt}\n>"
      input = gets.chomp.upcase.strip
      input = default if input.empty?
      break if yield(input)

      puts error_message
    end

    input
  end

  def select_options(options, promt)
    option = prompt_user("#{promt}\n#{make_list(options)}") do |input|
      element = input.to_i
      input.match?(/^\d$/) & element.between?(1, options.size)
    end

    options[option.to_i - 1]
  end
end
