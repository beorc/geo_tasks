# frozen_string_literal: true
require 'rack/test'
require 'rspec'
require 'cranky'
require 'database_cleaner'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.minimum_coverage 100
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'

Dir[File.join(settings.root, 'spec/factories/**/*_factory.rb')].each { |f| require f }

configure do
  Mongoid.load!('config/mongoid.yml', :test)
end

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:suite) do
    Factory.lint!
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def json_body
  JSON.parse(last_response.body)
end
