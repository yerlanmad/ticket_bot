# frozen_string_literal: true

class Timetable
  include Mongoid::Document

  field :route_id, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime

  validates :route_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
end
