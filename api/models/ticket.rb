# frozen_string_literal: true

class Ticket
  include Mongoid::Document

  field :passenger_id, type: String
  field :timetable_id, type: String
  field :user_id, type: String

  validates :passenger_id, presence: true
  validates :timetable_id, presence: true
end
