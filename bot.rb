#

require 'telegram/bot'
require 'net/http'
require 'json'

class TicketBot
  TOKEN = ENV['TICKET_BOT_TOKEN']
  API_HOST = 'http://localhost:4567/api/public/v1'

  def run
    Telegram::Bot::Client.run(TOKEN) do |bot|
      @markup ||= message_markup
      @bot = bot

      @bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          process_callback(message)
        when Telegram::Bot::Types::Message
          process_input(message)
        end
      end
    end
  end

  private

  def process_input(message)
    case message.text
    when /start/i
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: "Hi, #{message.from.first_name}!",
        reply_markup: @markup
        )
    when /,\s*/
      user_info = message.text.split(',').map(&:strip)
      
      data = {
        first_name:      user_info[0],
        last_name:       user_info[1],
        birth_date:      user_info[2],
        passport_number: user_info[3],
        start_date:      user_info[4],
        route_name:      user_info[5],
        user_id: message.chat.id
      }
      res = post_request("#{API_HOST}/tickets/buy", data)
      text = (@resp_code == '201' ? "Your data saved" : "Error: #{res}")

      @bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: @markup)
    else
      @bot.api.send_message(
        chat_id: message.chat.id,
        text: 'Sorry, I do not understand that',
        reply_markup: @markup
        )
    end
  end

  def process_callback(message)
    case message.data
    when 'buy_ticket'
      @bot.api.send_message(
        chat_id: message.from.id,
        text: "Write down data in following format:\n" \
              "First name, Last name, Birth Date, Passport No., Trip Date Time, Route Name"
        )
    when 'timetable'
      timetable = get_request("#{API_HOST}/timetables")
      text = timetable.each_with_object(''){ |timetable, memo| memo << "#{timetable['route']}, #{timetable['date']}\n" }
      @bot.api.send_message(
        chat_id: message.from.id,
        text: text,
        reply_markup: @markup
        )
    when 'my_tickets'
      tickets = get_request("#{API_HOST}/tickets/user/#{message.from.id}")
      text = tickets.each_with_object(''){ |ticket, memo| memo << "#{ticket['passenger_name']}, #{ticket['route']}, #{ticket['date']}\n" }
      @bot.api.send_message(
        chat_id: message.from.id,
        text: text,
        reply_markup: @markup
        )
    else
      @bot.api.send_message(chat_id: message.from.id, text: 'Bye!')
    end
  end

  def message_markup
    buttons_data = { 'timetable': 'Timetable', 'buy_ticket': 'Buy ticket', 'my_tickets': 'My tickets', 'stop': 'Stop' }
    buttons = buttons_data.map {
      |data, text| Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: data)
    }
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
  end
  
  def get_request(url)
    uri = URI(url)
    set_connection(uri)

    req = Net::HTTP::Get.new(uri)
    parse_response(req)
  end

  def post_request(url, body = '')
    uri = URI(url)
    set_connection(uri)

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = body.to_json

    parse_response(req)
  end

  def parse_response(request)
    res = @http.request(request)
    @resp_code = res.code
    JSON.parse(res.body) unless res.body.empty?
  end
  
  def set_connection(uri)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true if uri.instance_of?(URI::HTTPS)
  end
end
