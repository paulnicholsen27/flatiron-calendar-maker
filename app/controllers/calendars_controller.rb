require 'tzinfo'

class CalendarsController < ApplicationController

  def authorize
    client = Signet::OAuth2::Client.new(client_options)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to root_url
  end

  def get_calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    # https://stackoverflow.com/questions/51793689/cant-refresh-google-api-token-in-rails-app
    # client.update!(
    #   additional_parameters: {
    #     access_type: 'offline',
    #     prompt: 'consent'
    #   }
    # )
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    begin
      service.list_calendar_lists
        rescue Google::Apis::AuthorizationError
          # binding.pry
          response = client.refresh!
          session[:authorization] = session[:authorization].merge(response)
          retry
    end
  end

  def new
    all_calendars = get_calendars.items
    @calendar_list = all_calendars.select {|calendar| calendar.access_role=="owner"}
    @calendar_list.sort! { |a, b|  a.summary <=> b.summary }
    @timezones = TZInfo::Timezone.all_identifiers
  end

  def create
    calendar_id = params[:calendar][:id]
    module_number = params[:calendar][:module]
    start_date = params[:calendar][:start_date]
    start_time = params[:calendar][:start_time]
    time_zone = params[:calendar][:time_zone]
    lesson_hash = get_module_lectures(module_number)
    lesson_hash.each do |days_from_start, lesson_name|
      lesson_datetime = ActiveSupport::TimeZone[time_zone].parse("#{start_date} #{start_time}").advance(:days => days_from_start)
      new_event(calendar_id, lesson_datetime, lesson_name, time_zone)
    end
    redirect_to "https://calendar.google.com/calendar/embed?src=#{calendar_id}"
  end


  def new_event(calendar_id, lesson_datetime, lesson_name, time_zone)
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client

      event = Google::Apis::CalendarV3::Event.new(
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: lesson_datetime.to_datetime.rfc3339),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: lesson_datetime.advance(:hours => 1).to_datetime.rfc3339),
        summary: lesson_name
      )
      service.insert_event(calendar_id, event)

  end

  private

  def client_options
    {
      client_id: Rails.application.credentials.web[:client_id],
      client_secret: Rails.application.credentials.web[:client_secret],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth?access_type=offline&prompt=consent',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: calendars_url
    }
  end

  def get_module_lectures(module_number)
    # returns a hash with the day of the lecture as the key and the name of 
    # the lecture as the value.
    case module_number
    when "1"
      {0 => "Hashketball Review",
       1 => "Hashes and the Internet",
       2 => "Intro to OO",
       3 => "Object Relations (one to many)",
       4 => "Object Relations (many to many)",
       7 => "SQL Review",
       8 => "Intro to ORMs",
       9 => "Dynamic ORMs",
       10 => "Intro to ActiveRecord",
       14 => "ActiveRecord Associations",
       17 => "Intro to Testing",
       18 => "Intro to the Internet"
      }
    when "2"
      {
        0 => "Sinatra and MVC",
        1 => "Sinatra Forms and REST",
        2 => "Sinatra Forms and Associated Objects",
        3 => "Sinatra Forms and Associated Objects cont.",
        4 => "Intro to Rails",
        7 => "Rails Forms & REST",
        8 => "Rails Associations",
        9 => "Rails Forms and Validations",
        14 => "Sessions and Cookies",
        15 => "Rails Authorization"
      }
    when "3"
      pass
    when "4"
      pass
    when "5"
      pass
    else 
      "Module number must be an integer between 1 and 5, inclusive."
    end
  end

end