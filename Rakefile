# frozen_string_literal: true
require_relative 'models'

task :console do
  require 'pry'
  ARGV.clear
  Pry.start
end

namespace :db do
  task :create_indexes do
    Mongoid.load!('config/mongoid.yml')

    Task.create_indexes
    User.create_indexes
    TaskAssignment.create_indexes
  end

  task :seed do
    Mongoid.load!('config/mongoid.yml')

    if User.count.zero?
      3.times do |n|
        User.create(name: "manager#{n}", role: 'manager', token: User.generate_token)
      end
      3.times do |n|
        User.create(name: "driver#{n}", role: 'driver', token: User.generate_token)
      end
    end
  end
end
