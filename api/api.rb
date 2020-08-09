# frozen_string_literal: true

class Api < Sinatra::Base
  register Sinatra::Namespace

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 400, { message: 'Invalid JSON' }.to_json
    end

    def station
      @station ||= Station.where(id: params[:id]).first
    end

    def route
      @route ||= Route.where(id: params[:id]).first
    end

    def train
      @train ||= Train.where(id: params[:id]).first
    end

    def passenger
      @passenger ||= Passenger.where(id: params[:id]).first
    end

    def timetable
      @timetable ||= Timetable.where(id: params[:id]).first
    end

    def ticket
      @ticket ||= Ticket.where(id: params[:id]).first
    end

    def halt_if_not_found!(record)
      halt(404, { message: 'Record Not Found' }.to_json) unless record
    end

    def buy_ticket(params)
      route = Route.where(name: params['route_name']).first
      raise SearchError, 'Route Not Found' unless route
  
      timetable = Timetable.where(route_id: route.id.to_s, start_date: params['start_date']).first
      raise SearchError, 'Timetable Not Found' unless timetable

      passenger = Passenger.where(passport_number: params['passport_number']).first
      if !passenger
        args = { first_name: params['first_name'], last_name: params['last_name'], birth_date: params['birth_date'], passport_number: params['passport_number'] }
        passenger = Passenger.new(args)
        halt 422, passenger.errors.to_json unless passenger.save
      end

      ticket = Ticket.new({passenger_id: passenger.id.to_s, timetable_id: timetable.id.to_s, user_id: params['user_id']})
      halt 422, ticket.errors.to_json unless ticket.save
    end
  end

  namespace '/api/public/v1' do
    get '/timetables' do
      timetables = Timetable.all
      timetables.map { |timetable| TimetableSerializer.new(timetable) }.to_json
    end

    get '/tickets/user/:id' do
      tickets = Ticket.where(user_id: params[:id])
      tickets.map { |ticket| TicketSerializer.new(ticket) }.to_json
    end

    post '/tickets/buy' do
      buy_ticket(json_params)
      status 201
    rescue SearchError => e
      halt(404, { message: e }.to_json)      
    end
  end

  namespace '/api/admin/v1' do
    get '/stations' do
      stations = Station.all
      stations.to_json
    end

    get '/stations/:id' do
      halt_if_not_found!(station)
      station.to_json
    end

    post '/stations' do
      station = Station.new(json_params)
      halt 422, station.errors.to_json unless station.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/stations/#{station.id}"
      status 201
    end

    get '/routes' do
      routes = Route.all
      routes.map { |route| RouteSerializer.new(route) }.to_json
    end

    get '/routes/:id' do
      halt_if_not_found!(route)
      route.to_json
    end

    post '/routes' do
      route = Route.new(json_params)
      halt 422, route.errors.to_json unless route.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/routes/#{route.id}"
      status 201
    rescue SearchError => e
      halt(404, { message: e }.to_json)
    end

    get '/trains' do
      trains = Train.all
      trains.to_json
    end

    get '/trains/:id' do
      halt_if_not_found!(train)
      train.to_json
    end

    post '/trains' do
      train = Train.new(json_params)
      halt 422, train.errors.to_json unless train.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/trains/#{train.id}"
      status 201
    end

    patch '/trains/:id' do
      halt_if_not_found!(train)

      train.update_attributes(json_params)
      train.to_json
    end

    patch '/trains/:id/route/:route_id' do
      halt_if_not_found!(train)

      train.accept_route(params[:route_id])
      train.to_json
    rescue SearchError => e
      halt(404, { message: e }.to_json)
    end

    get '/passengers' do
      passengers = Passenger.all
      passengers.to_json
    end

    get '/passengers/:id' do
      halt_if_not_found!(passenger)
      passenger.to_json
    end

    post '/passengers' do
      passenger = Passenger.new(json_params)
      halt 422, passenger.errors.to_json unless passenger.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/passengers/#{passenger.id}"
      status 201
    end

    get '/tickets' do
      tickets = Ticket.all
      tickets.map { |ticket| TicketSerializer.new(ticket) }.to_json
    end

    get '/tickets/:id' do
      halt_if_not_found!(ticket)
      ticket.to_json
    end

    post '/tickets' do
      ticket = Ticket.new(json_params)
      halt 422, ticket.errors.to_json unless ticket.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/tickets/#{ticket.id}"
      status 201
    end

    get '/timetables/:id' do
      halt_if_not_found!(timetable)
      timetable.to_json
    end

    post '/timetables' do
      timetable = Timetable.new(json_params)
      halt 422, timetable.errors.to_json unless timetable.save

      response.headers['Location'] = "#{base_url}/api/admin/v1/timetables/#{timetable.id}"
      status 201
    end
  end
end
