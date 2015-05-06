ENVIRONMENT ||= :dev
EXTRA_FILES_TO_LOAD ||= []

system 'rm Gemfile' if File.exist?('Gemfile')
File.write('Gemfile', <<-GEMFILE)
  source 'https://rubygems.org'

  gem 'activesupport'
  gem 'octokit'

  group :specs do
    gem 'vcr'
    gem 'webmock'
    gem 'minitest-reporters'
    gem 'database_cleaner'
  end
GEMFILE

system 'bundle install'

require 'bundler'
Bundler.setup(:default, ENVIRONMENT)

require 'logger'

require 'active_support/all'
require 'octokit'

(%w(config/initializer.rb models/*.rb) + EXTRA_FILES_TO_LOAD).each do |path|
  location = File.expand_path(path, __dir__)
  Dir[location].each { |f| require f }
end
