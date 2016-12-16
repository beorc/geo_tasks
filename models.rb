# frozen_string_literal: true
require 'mongoid'
require 'mongoid/geospatial'
require 'aasm'

module Mongoid
  module Document
    def as_json(options = {})
      attrs = super
      attrs['id'] = attrs['_id'].to_s
      attrs
    end
  end
end

class User
  include Mongoid::Document

  field :token, type: String
  field :name, type: String
  field :role, type: String

  has_many :tasks, dependent: :restrict

  validates :name, presence: true
  validates :token, presence: true, uniqueness: { case_sensitive: true }
  validates :role, inclusion: { in: %w(manager driver) }

  index({ token: 1 }, unique: true)

  def self.generate_token
    SecureRandom.urlsafe_base64
  end
end

class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  include AASM

  field :state

  aasm column: :state do
    state :available, initial: true
    state :assigned
    state :done

    event :assign do
      transitions from: :available, to: :assigned
    end

    event :finish do
      transitions from: :assigned, to: :done
    end
  end

  has_one :task_assignment

  field :pickup_point, type: Point, spatial: true
  field :delivery_point, type: Point

  validates :pickup_point, :delivery_point, presence: true
  validates :state, inclusion: { in: %w(available assigned done) }
  validates :task_assignment, presence: true, if: :assigned?

  spatial_scope :pickup_point

  index(state: 1)

  def assign_to!(user)
    begin
      TaskAssignment.create!(task: self, user: user)
    rescue Mongo::Error::OperationFailure => e
      handle_duplicate_key_error(e, 'Task is already assigned') || raise(e)
    end

    assign!
  end

  def user
    TaskAssignment.where(task: self).first.try(:user)
  end

  private

  def handle_duplicate_key_error(e, message)
    e.message =~ /^E11000 / && throw(:halt, [409, message])
  end
end

class TaskAssignment
  include Mongoid::Document

  belongs_to :task
  belongs_to :user

  index({ task_id: 1 }, unique: true)
end
