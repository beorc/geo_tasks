# frozen_string_literal: true
require 'sinatra'
require 'mongoid'

configure do
  Mongoid.load!('config/mongoid.yml', settings.environment)
end

get '/' do
  '/'
end
