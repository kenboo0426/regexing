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

  TIMES_REQUIRED_IN_COMPLETE = 5
  @current_gate = nil
  @incorrect_number = 0

  class << self
    attr_reader :current_gate, :incorrect_number

    def start
      @current_gate = 1
      opening_message
      TIMES_REQUIRED_IN_COMPLETE.times do
        question
      end
      complete_process
    rescue WrongAnswerError
    end

    def fetch_question(question_number: nil)
      level = current_level
      questions = YAML.load_file("./lib/questions/#{level}.yml")
      if question_number
        questions[question_number]
      else
        questions.to_a.sample
      end
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
        Typing regex type： [a-z0-9]


      START

      warn(opening_message)
      print 'Press Enter to start!'
      Readline.readline
    end

    def question(question_number: nil, question_detail: nil)
      question_number, question_detail = fetch_question unless question_number || question_detail
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

      check(input_regex, question_number, question_detail)
    end

    def check(input_regex, question_number, question_detail)
      is_all_passed = true
      question_detail['pass'].each_with_index do |text, i|
        if match?(text, input_regex)
          puts "✅  #{i + 1}. passed"
        else
          puts "❌  #{i + 1}. not passed"
          is_all_passed = false
        end
      end

      question_detail['not_pass'].each_with_index do |text, i|
        if !match?(text, input_regex)
          puts "✅  #{i + 1}. passed"
        else
          puts "❌  #{i + 1}. not passed"
          is_all_passed = false
        end
      end

      if is_all_passed
        passed_process
      else
        failed_process(question_detail, question_number)
      end
    end

    def match?(target_text, input_regex)
      input_regex = Regexp.new(input_regex) unless input_regex.instance_of?(Regexp)

      matched_text = target_text.match(input_regex).to_s
      target_text.eql?(matched_text)
    end

    def passed_process
      passed_message = <<~MESSAGE

        Great!!  Next question!

      MESSAGE

      warn(passed_message)
      @current_gate += 1
    end

    def failed_process(question_detail, question_number)
      failed_message = <<~MESSAGE
        Correct answer sample is "#{question_detail['answer']}"


      MESSAGE

      warn(failed_message)
      @incorrect_number += 1
      incomplete_process if @incorrect_number >= 3
      question(question_number:, question_detail:)
    end

    def complete_process
      complete_message = <<~MESSAGE
        Congratulations!!
        You are a regular expression master🎉
      MESSAGE

      warn(complete_message)
    end

    def incomplete_process
      @incorrect_number = 0
      incomplete_message = <<~MESSAGE
        You fail 🫣
        You made a mistake 3 times.
        Aim to be a regular expression master.
      MESSAGE

      warn(incomplete_message)
      raise WrongAnswerError
    end
  end
end
