# frozen_string_literal: true

require 'readline'
require 'yaml'
require 'byebug'
require 'humanize'

module Regexing
  class Error < StandardError; end

  # Error that will be raised if @current_gate is invalid in fetch_question method
  class InvalidGateError < Error; end

  # Error that will be raised if the answer is wrong
  class WrongAnswerError < Error; end

  TIMES_REQUIRED_IN_COMPLETE = 5
  TIMES_REQUIRED_IN_INCOMPLETE = 3
  @current_gate = nil
  @incorrect_number = 0
  @passed_questions = []

  class << self
    attr_reader :current_gate, :incorrect_number, :passed_questions

    def start
      @current_gate = 1
      opening_message
      TIMES_REQUIRED_IN_COMPLETE.times do
        question
      end
      complete_process
    rescue WrongAnswerError => e
      incomplete_process(e.message)
    ensure
      @incorrect_number = 0
      @passed_questions = []
    end

    private

    def fetch_question(question_number: nil)
      questions = YAML.load_file("./lib/questions/#{current_level}.yml")
      if question_number
        questions.to_a.find { |q| q[0] == question_number }
      else
        exclude_questions = @passed_questions.map do |q|
          level, number = q.split(':')
          number if level == current_level
        end.compact
        questions = questions.except('example', *exclude_questions)

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
        Welcome Regexing!!
        There are 5 questions. The difficulty level will gradually increase.

        -- Example --------------------
      START

      warn(opening_message)
      question(question_number: 'example', example: true)
      answer_manner = <<~ANSWER
        -------------------------------
        Typing regex type： \A[a-z]+

      ANSWER
      warn(answer_manner)
      Readline.readline('Press Enter to start!')
    end

    def question(question_number: nil, question_detail: nil, **option)
      question_number, question_detail = fetch_question(question_number:) unless question_number && question_detail
      question_should_pass_array = question_detail['pass']
      question_should_pass = <<~QUESTION
        Pass questions
        1. "#{question_should_pass_array[0]}"
        2. "#{question_should_pass_array[1]}"
        3. "#{question_should_pass_array[2]}"
        -------------------------------
      QUESTION

      warn(question_should_pass)

      question_should_not_pass_array = question_detail['not_pass']
      question_should_not_pass = <<~QUESTION
        Not pass questions
        4. "#{question_should_not_pass_array[0]}"
        5. "#{question_should_not_pass_array[1]}"
        6. "#{question_should_not_pass_array[2]}"
      QUESTION
      warn(question_should_not_pass)
      return if option[:example]

      input_regex = Readline.readline('Typing regex type： ')
      check(input_regex, question_number, question_detail)
    end

    def check(input_regex, question_number, question_detail)
      is_all_passed = true
      question_detail['pass'].each.with_index(1) do |text, i|
        if match?(text, input_regex)
          puts "✅  #{i}. passed"
        else
          puts "❌  #{i}. not passed"
          is_all_passed = false
        end
      end
      puts '--------------------------------------------'
      question_detail['not_pass'].each.with_index(4) do |text, i|
        if !match?(text, input_regex)
          puts "✅  #{i}. passed"
        else
          puts "❌  #{i}. not passed"
          is_all_passed = false
        end
      end

      if is_all_passed
        passed_process(question_number)
      else
        failed_process(question_detail, question_number)
      end
    end

    def match?(target_text, input_regex)
      raise RegexpError if own_include?(target_text, input_regex)

      input_regex = Regexp.new(input_regex)
      matched_text = target_text.to_s.match(input_regex).to_s
      !matched_text.empty? && target_text.eql?(matched_text)
    rescue RegexpError
      false
    end

    def own_include?(target_text, input_regex)
      input_regex.include?(target_text.to_s)
    end

    def passed_process(question_number)
      passed_message = <<~MESSAGE

        Great!!  Next question!

      MESSAGE

      warn(passed_message)
      @passed_questions << "#{current_level}:#{question_number}"
      @current_gate += 1
    end

    def failed_process(question_detail, question_number)
      @incorrect_number += 1
      raise WrongAnswerError, question_detail['answer'] if @incorrect_number >= TIMES_REQUIRED_IN_INCOMPLETE

      message = if (TIMES_REQUIRED_IN_INCOMPLETE - @incorrect_number) == 1
                  'one more time'
                else
                  "#{(TIMES_REQUIRED_IN_INCOMPLETE - @incorrect_number).humanize} more times"
                end
      failed_message = <<~MESSAGE
        If you make a mistake #{message}, you will fail

      MESSAGE
      warn(failed_message)
      question(question_number:, question_detail:)
    end

    def complete_process
      complete_message = <<~MESSAGE
              Congratulations!!
              You are a regular expression master🎉


        .                                                                             (Nm-                                                           ....
          .WMMMMMMMMNN+.                                                              ?MB:                                                          .dM#:
          .WMD`    -?MMb        ..             ..    `         ..       `        `    ``      `    .            ..    `         ..         `    ..   dM#!
          .WMD       dM#<    (gMNNMNa,     .&NMNNNmJdMl    .+NNNNMm+.  .WMN+   .gM#>  JMH_  .MNA+MNNMNm,     .gMMNNN&dM#     (gMNNMNm.    jMNadMN#   dM#!
          .WMD      .NM@`  .dM#=!_?TMNo   (MMB=!_?TMMMl   (MM9^~?7MMm-  .vMNo..dMB!   JM#:  -MMM8!~_?MMN_  .gMMY!~?7MMM#`  .dM#=!~?TMNe   JMMMY<!`   dMK~   `
          .WMNgggggNMM9!  .dM#_.....JMN- .dMD      JMMl  .MMD.....(MNy    ?MMmMMY`    JM#:  -MMD     (MM}  (MS{      MM#` .dM#:.....dM#-  JMM}       dMK~
          .WM@777TMM#_    (dMMMMMMMMMMM\ (MNI      (MMl  jMMMMMMMMMMM@     (MMM%      JM#:  -MNI     (MM}  dM#_      dM#` .WMMMMMMMMMMMl  JMN:       dMD~
          .WMD    (MM#.   .dMH!           MMN-    .jMMl  (MNr             .dMMMNe.    JM#:  -MNI     (MM}  (MNe.    .MM#` .dM#_           JMN:        ``    `
          .WMD     (MMN,   ?MMm.....gNK!  (HMNm&JgMMMMl  .TMNe....(gNC   (MM3`?MMm.   JM#:  -MNI     (MM}   ?MMNa++gMMM#`  (MMm.....gNK~  JMN:      .(ge.
          .WMD      .MMN+   _TMMNNMMM9!     ?TWHH9^<MMl    ?HMMNNMMB=  .jM#%   (MMN,  JM#:  -MNI     (MM}    .7WHHBY!dM#`   .7MMNNMMM5`   JMN:      ,MMM
                                _~`       .JJ.     (MM{       `~~`                                         .JJ,.    .dM8        _~`                   ``   `
                                          -TMMNgggMM#=`                                                     ?MMNmgggMM8!
                                             ?""""7!                                                          ?7""""7`
      MESSAGE

      warn(complete_message)
    end

    def incomplete_process(answer)
      incomplete_message = <<~MESSAGE
        Correct answer sample is "#{answer}"

        You fail 🫣
        You made a mistake #{TIMES_REQUIRED_IN_INCOMPLETE} times.
        Aim to be a regular expression master!
      MESSAGE

      warn(incomplete_message)
    end
  end
end
