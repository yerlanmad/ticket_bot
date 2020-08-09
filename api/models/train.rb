# frozen_string_literal: true

class Train
  include Mongoid::Document

  field :number, type: String
  field :type, type: String
  field :wagons, type: Array, default: []
  field :route, type: String

  validates :number, presence: true
  validates :type, presence: true

  index({ number: 1 }, { unique: true })

  def accept_route(route_id)
    route = Route.where(id: route_id).first
    raise SearchError, 'Route Not Found' unless route

    station = Station.where(id: route.stations.first).first
    raise SearchError, 'First Station Not Found' unless station

    update_attributes(route: route.id.to_s)
    station.accept(id.to_s)
  end
end
