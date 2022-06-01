# frozen_string_literal: true

require 'yaml'

RSpec.describe Regexing do
  def all_passed?(question_detail)
    question_detail['pass'].each do |q|
      return false unless match?(q, question_detail['answer'])
    end
    question_detail['not_pass'].each do |q|
      return false if match?(q, question_detail['answer'])
    end
  end

  def match?(target_text, input_regex)
    input_regex = Regexp.new(input_regex)
    matched_text = target_text.to_s.match(input_regex).to_s
    !matched_text.empty? && target_text.eql?(matched_text)
  end

  describe 'questions answer is correct in yml' do
    # it 'beginner questions' do
    #   is_not_passed_questions = YAML.load_file('./lib/questions/beginner.yml').to_a.select do |q|
    #     all_passed?(q[1]).is_a?(FalseClass)
    #   end
    #   expect(is_not_passed_questions.empty?).to be_truthy
    # end

    it 'intermediate questions' do
      is_not_passed_questions = YAML.load_file('./lib/questions/intermediate.yml').to_a.select do |q|
        all_passed?(q[1]).is_a?(FalseClass)
      end
      expect(is_not_passed_questions.empty?).to be_truthy
    end

    it 'advanced questions' do
      is_not_passed_questions = YAML.load_file('./lib/questions/advanced.yml').to_a.select do |q|
        all_passed?(q[1]).is_a?(FalseClass)
      end
      expect(is_not_passed_questions.empty?).to be_truthy
    end
  end
end
