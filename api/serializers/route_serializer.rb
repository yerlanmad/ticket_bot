# frozen_string_literal: true

class RouteSerializer
  def initialize(route)
    @route = route
  end

  def as_json(*)
    data = {
      id: @route.id.to_s,
      name: @route.name,
      stations: stations(@route.stations)
    }
    data[:errors] = @route.errors if @route.errors.any?
    data
  end

  def stations(ids)
    ids.each_with_object([]) do |id, memo|
      station = Station.where(id: id).first
      trains = trains(station.trains)
      memo << { name: station.name, trains: trains }
    end
  end

  def trains(ids)
    ids.each_with_object([]) do |id, memo|
      train = Train.where(id: id).first
      memo << { number: train.number, type: train.type, wagons_amount: train.wagons.size }
    end
  end
end
