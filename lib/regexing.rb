# frozen_string_literal: true

module Regexing
  class Error < StandardError; end

  class << self
    def start
      p a = <<~START
        start!!!!!!
      START

      text = gets.chomp
      p text
    end
  end
end
