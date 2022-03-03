module Modules
  module Validation
    def validate_name(name:)
      return name.length > 2 && name.length < 21
    end

    def validate_guess(guess:)
      return guess.length == 4 && guess.scan(/[1-6]{4}/).length == 1
    end
  end
end
