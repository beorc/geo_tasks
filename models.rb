require 'mongoid'
require 'mongoid/geospatial'
require 'aasm'

module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
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

  index({ token: 1 }, { unique: true })

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

  belongs_to :user, required: false
  field :pickup_point, type: Point, spatial: true
  field :delivery_point, type: Point

  validates :pickup_point, :delivery_point, presence: true
  validates :state, inclusion: { in: %w(available assigned done) }

  spatial_scope :pickup_point

  index({ state: 1 })

end
