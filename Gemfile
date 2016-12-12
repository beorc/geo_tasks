# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.3'

gem 'aasm'
gem 'bson_ext'
gem 'mongoid'
gem 'mongoid-geospatial', require: 'mongoid/geospatial'
gem 'mongoid_optimistic_locking'
gem 'puma'
gem 'rack'
gem 'rake'
gem 'sinatra'

group :development do
  gem 'pry', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'cranky'
  gem 'database_cleaner'
  gem 'rack-test'
  gem 'rspec', require: false
  gem 'simplecov', require: false
end
