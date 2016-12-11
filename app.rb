# frozen_string_literal: true
require 'sinatra'
require 'mongoid'
require 'mongoid/geospatial'
require_relative 'models'

configure do
  Mongoid.load!('config/mongoid.yml', settings.environment)
end

get '/tasks' do
  status 200
end
