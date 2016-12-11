# frozen_string_literal: true
require 'sinatra'
require 'mongoid'
require 'mongoid/geospatial'
require_relative 'models'
require_relative 'sinatra/authentication'
require_relative 'sinatra/authorization'

configure do
  Mongoid.load!('config/mongoid.yml', settings.environment)

  error JSON::ParserError do |e|
    status 400
    e.message
  end
end

helpers do
  def request_payload
    return @request_payload if @request_payload
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end

  def fetch_token
    pattern = /^Bearer /.freeze
    header = request.env['HTTP_AUTHORIZATION']

    return '' unless header && header.match(pattern)

    header.sub(pattern, '')
  end
end

before do
  authenticate!(fetch_token)
  content_type :json
end

post '/tasks' do
  authorize_task_create!(current_user)

  task = Task.new do |t|
    t.pickup_point = request_payload['pickup_point']
    t.delivery_point = request_payload['delivery_point']
  end

  if task.save
    status 201
    task.to_json
  else
    status 422
    { errors: task.errors.to_h }.to_json
  end
end
