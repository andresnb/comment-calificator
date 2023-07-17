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
end
