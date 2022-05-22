# frozen_string_literal: true

require_relative 'lib/regexing/version'

Gem::Specification.new do |spec|
  spec.name = 'regexing'
  spec.version = Regexing::VERSION
  spec.authors = ['kenboo0426']
  spec.email = ['kenshin.kenboo@gmail.com']

  spec.summary = 'Training Ruby regular expressions in CLI'
  spec.description = 'Dialogueally ask questions and answer'
  spec.homepage = 'https://github.com/kenboo0426/regexing'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kenboo0426/regexing'
  spec.metadata['changelog_uri'] = 'https://github.com/kenboo0426/regexing/blob/master/CHANGELOG.md'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
