module Entities
  class Game
    include Modules::Validation
    include Modules::Uploader

    ATTENTION_MSG = "You have passed unexpected command. Please choose one from listed commands"

    def initialize
      while true
        puts "You are in main menu, let me know what you want to do"
        command = gets.chomp
        case command
        when 'start'
          result = start
          if result[:exit]
            puts "You don't finish game and spend #{result[:attempts_used]} attempts and #{result[:hints_used]} hints"
            exit
            break
          elsif result[:game_status]
            puts "Congrats! You won with #{result[:attempts_used]} attempts and #{result[:hints_used]} hints"
            puts "Do you want to save your result?"
            while true
              save_game = gets.chomp
              case save_game
              when "yes"
                result[:user].update_attributes(attempts: result[:attempts], attempts_used: result[:attempts_used],
                                                hints: result[:hints], hints_used: result[:hints_used],
                                                difficulty: result[:difficulty])
                result[:user].save
                break
              when "no"
                break
              else
                unexpected_command
              end
            end
          else
            puts "You lost because your attempts ended."
          end
        when 'rules'
          rules
        when 'stats'
          stats
        when 'exit'
          exit
          break
        else
          unexpected_command
        end
      end
    end

    def start
      user = set_user
      puts "Choose difficulty easy, meduim, hell"
      difficulty = gets.chomp
      case difficulty.to_sym
      when :easy
        hints = 2
        attempts = 15
      when :medium
        hints = 1
        attempts = 10
      when :hell
        hints = 1
        attempts = 5
      else
        unexpected_command
        start
        return
      end
      game_status = false
      hints_used = 0
      attempts_used = 0
      digits = ['1','2','3','4','5','6']
      rcode = []
      exit = false
      4.times { rcode << digits.sample }
      puts rcode.join('')
      hints_digits = rcode.sample(hints)
      while true
        code = rcode.dup
        puts "You used attempts: #{attempts_used} and hints: #{hints_used}. #{attempts} attempts and #{hints} hints left."
        puts "Waiting for command or code"
        guess = gets.chomp
        case guess
        when 'exit'
          exit = true
          break
        when 'hint'
          hints_used = get_hint(hints_used: hints_used, hints_digits: hints_digits)
          next
        else
          if guess.length != 4 || guess.scan(/[1-6]{4}/).length != 1
            unexpected_command
            next
          end
        end
        guess = guess.split('')
        attempts_used += 1
        answer = ''
        guess.each_with_index do |digit, index|
          if code[index] == digit
            answer += '+'
            guess[index] = "+#{digit}"
            code[index] = "-#{digit}"
          end
        end

        guess.each_with_index do |digit, index|
          if code.include?(digit)
            answer += '-'
            guess[index] = "+#{digit}"
            i = code.index(digit)
            code[i] = "-#{digit}"
          end
        end

        puts answer
        if answer == '++++'
          game_status = true
          break
        elsif attempts_used == attempts
          break
        end
      end

      puts "Correct code: #{rcode.join('')}" unless game_status
      return {user: user, difficulty: difficulty, game_status: game_status, attempts: attempts, attempts_used: attempts_used, hints: hints, hints_used: hints_used, exit: exit}
    end

    def rules
      puts "*  Codebreaker is a logic game in which a code-breaker tries to break a secret code created by a code-maker. The codemaker, which will be played by the application we’re going to write, creates a secret code of four numbers between 1 and 6.\n*  The codebreaker gets some number of chances to break the code (depends on chosen difficulty). In each turn, the codebreaker makes a guess of 4 numbers. The codemaker then marks the guess with up to 4 signs - + or - or empty spaces.\n*  A + indicates an exact match: one of the numbers in the guess is the same as one of the numbers in the secret code and in the same position. For example:\nSecret number - 1234\nInput number - 6264\nNumber of pluses - 2 (second and fourth position)\n*  A - indicates a number match: one of the numbers in the guess is the same as one of the numbers in the secret code but in a different position. For example:\nSecret number - 1234\nInput number - 6462\nNumber of minuses - 2 (second and fourth position)\n*  An empty space indicates that there is not a current digit in a secret number.\n*  If codebreaker inputs the exact number as a secret number - codebreaker wins the game. If all attempts are spent - codebreaker loses.\n*  Codebreaker also has some number of hints(depends on chosen difficulty). If a user takes a hint - he receives back a separate digit of the secret code."
    end

    def stats
      unless store.nil?
        puts "   Name#{" "*16} Difficulty Attempts used Attempts Hints used Hints "
        store.each_with_index do |user, index|
          puts "#{index + 1}. #{user.name}#{" "*(20 - user.name.length)} #{user.difficulty}#{" "*(10 - user.difficulty.length)} #{user.attempts_used}#{" "*(13-user.attempts_used.to_s.length)} #{user.attempts}#{" "*(8-user.attempts.to_s.length)} #{user.hints_used}#{" "*(10-user.hints_used.to_s.length)} #{user.hints}#{" "*(5-user.hints.to_s.length)}"
        end
      else
        puts "Statistics empty"
      end
    end

    def exit
      puts "Goodbye"
    end

    def get_hint(hints_used:, hints_digits:)
      if hints_used < hints_digits.length
        puts hints_digits[hints_used]
        hints_used += 1
      else
        puts "You have taken all hints, code contains #{hints_digits.join(', ')}"
      end

      return hints_used
    end

    def unexpected_command
      puts ATTENTION_MSG
    end

    def users
      store || []
    end

    def set_user_name
      puts "Type your name"
      name = gets.chomp
      if validate_name(name: name)
        user = Entities::User.new(name: name)
      else
        puts "Your input wrong"
        start
        return
      end
    end
  end
end
