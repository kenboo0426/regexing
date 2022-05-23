# frozen_string_literal: true

require 'readline'
require 'yaml'
require 'byebug'

module Regexing
  class Error < StandardError; end

  # Error that will be raised if @current_gate is invalid in fetch_question method
  class InvalidGateError < Error; end

  # Error that will be raised if the answer is wrong
  class WrongAnswerError < Error; end

  @current_gate = nil
  @incorrect_number = 0

  class << self
    attr_reader :current_gate, :incorrect_number

    def start
      @current_gate = 1
      opening_message
      3.times do
        question
      end
      complete_message
    end

    def fetch_question
      level = current_level
      YAML.load_file("./lib/questions/#{level}.yml").to_a.sample
    end

    def current_level
      case @current_gate
      when 1..2
        'beginner'
      when 3..4
        'intermediate'
      when 5
        'advanced'
      else
        raise InvalidGateError,
              'unexpected error. Please contact regexing author <kenshin.kenboo@gmail.com>'
      end
    end

    def opening_message
      opening_message = <<~START
        Welcom Regexing!!
        There are 5 questions. The difficulty level will gradually increase.
        We'll start.

        example:
        Typing regex type： [^1-9]


      START

      warn(opening_message)
      print 'Press Enter to start!'
      Readline.readline
    end

    def question
      _question_number, question_detail = fetch_question
      question_should_pass_array = question_detail['pass']
      question_should_pass = <<~QUESTION
        1. "#{question_should_pass_array[0]}"
        2. "#{question_should_pass_array[1]}"
        3. "#{question_should_pass_array[2]}"
      QUESTION

      warn(question_should_pass)

      question_should_not_pass_array = question_detail['not_pass']
      question_should_not_pass = <<~QUESTION
        1. "#{question_should_not_pass_array[0]}"
        2. "#{question_should_not_pass_array[1]}"
        3. "#{question_should_not_pass_array[2]}"
      QUESTION
      warn(question_should_not_pass)

      print 'Typing regex type： '
      input_regex = Readline.readline

      check(input_regex, question_detail)
    end

    def check(input_regex, question_detail)
      question_detail['pass'].each do |text|
        if match?(text, input_regex)
          p '正解です'
        else
          p '違います'
          raise WrongAnswerError
        end
      end

      question_detail['not_pass'].each do |text|
        if !match?(text, input_regex)
          p '正解です'
        else
          p '違います'
          raise WrongAnswerError
        end
      end
      answered_message
      @current_gate += 1
    rescue WrongAnswerError
      p "答え: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i"
      @incorrect_number += 1
    end

    def match?(target_text, input_regex)
      input_regex = Regexp.new(input_regex) unless input_regex.instance_of?(Regexp)

      matched_text = target_text.match(input_regex).to_s
      target_text.eql?(matched_text)
    end

    def answered_message
      answered_message = <<~ANSWERED
        Great!!
        Next question!
      ANSWERED

      warn(answered_message)
    end

    def complete_message
      complete_message = <<~MESSAGE
        Congratulations!!
        You are a regular expression master🎉
      MESSAGE

      warn(complete_message)
    end
  end
end
