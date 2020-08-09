# frozen_string_literal: true

class Route
  include Mongoid::Document

  def initialize(params)
    first_station = Station.where(id: params['first_station']).first
    raise SearchError, 'First Station Not Found' unless first_station

    last_station = Station.where(id: params['last_station']).first
    raise SearchError, 'Last Station Not Found' unless last_station

    name = "#{first_station.name}-#{last_station.name}"
    args = { name: name, stations: [first_station.id.to_s, last_station.id.to_s] }
    super(args)
  end

  field :name, type: String
  field :stations, type: Array, default: []

  validates :name, presence: true

  index({ name: 1 }, { unique: true })
end
