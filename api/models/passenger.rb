# frozen_string_literal: true

class Passenger
  include Mongoid::Document

  field :first_name, type: String
  field :last_name, type: String
  field :birth_date, type: DateTime
  field :passport_number, type: String

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :passport_number, presence: true

  index({ passport_number: 1 }, { unique: true })
end
