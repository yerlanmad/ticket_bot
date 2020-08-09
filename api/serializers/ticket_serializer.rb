# frozen_string_literal: true

class TicketSerializer
  def initialize(ticket)
    @ticket = ticket
  end

  def as_json(*)
    data = {
      id: @ticket.id.to_s,
      passenger_name: passenger_name(@ticket.passenger_id),
      route: route(@ticket.timetable_id),
      date: date(@ticket.timetable_id)
    }
    data[:errors] = @ticket.errors if @ticket.errors.any?
    data
  end

  def passenger_name(id)
    passenger = Passenger.where(id: id).first
    "#{passenger.first_name} #{passenger.last_name}"
  end

  def route(id)
    route_id = Timetable.where(id: id).first.route_id
    Route.where(id: route_id).first.name
  end

  def date(id)
    timetable = Timetable.where(id: id).first
    "#{timetable.start_date} - #{timetable.end_date}"
  end
end

