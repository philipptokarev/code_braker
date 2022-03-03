module Entities
  class User
    include Modules::Uploader

    attr_reader :name, :attempts, :attempts_used, :hints, :hints_used, :difficulty

    def initialize(name:)
      @name = name
    end

    def update_attributes(attempts:, attempts_used:, hints:, hints_used:, difficulty:)
      @attempts = attempts
      @attempts_used = attempts_used
      @hints = hints
      @hints_used = hints_used
      @difficulty = difficulty
    end
  end
end
