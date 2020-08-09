# frozen_string_literal: true

class TimetableSerializer
  def initialize(timetable)
    @timetable = timetable
  end

  def as_json(*)
    data = {
      id: @timetable.id.to_s,
      route: route(@timetable.route_id),
      date: "#{@timetable.start_date} - #{@timetable.end_date}"
    }
    data[:errors] = @timetable.errors if @timetable.errors.any?
    data
  end

  def route(id)
    Route.where(id: id).first.name
  end
end
