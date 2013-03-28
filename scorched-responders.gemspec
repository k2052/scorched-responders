$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'scorched-responders/version'

Gem::Specification.new 'scorched-responders', ScorchedResponders::VERSION do |s|
  s.summary               = 'Responders for the Scorched framework'
  s.description           = 'Keep your controllers DRY'
  s.authors               = ['K-2052']
  s.email                 = 'k@2052.me'
  s.homepage              = 'http://k2052.me'
  s.files                 = Dir.glob(`git ls-files`.split("\n") - %w[.gitignore])
  s.test_files            = Dir.glob('spec/**/*_spec.rb')
  s.rdoc_options          = %w[--line-numbers --inline-source --title Scorched --encoding=UTF-8]
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'scorched',      '~> 0.7'
  s.add_dependency 'rake',          '~> 10.0.0'
  s.add_dependency 'activesupport', '~> 3.2.0'
  s.add_dependency 'i18n',          '~> 0.6'

  s.add_development_dependency 'rack-test',    '~> 0.6'
  s.add_development_dependency 'webrat',       '~> 0.7.3'
  s.add_development_dependency 'rspec',        '~> 2.9'
  s.add_development_dependency 'slim',         '~> 1.3.6'
  s.add_development_dependency 'rabl'
  s.add_development_dependency 'bson_ext',     '1.5'
  s.add_development_dependency 'mongo_mapper', '~> 0.12.0'
end
