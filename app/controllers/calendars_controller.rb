class CalendarsController < ApplicationController

  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to calendars_url
  end

  def get_calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    service.list_calendar_lists
  end

  def new
    all_calendars = get_calendars.items
    @calendar_list = all_calendars.select {|calendar| calendar.access_role=="owner"}
    @calendar_list.sort! { |a, b|  a.summary <=> b.summary }
  end

  def create
  end

  # def list
  #   render :calendar_list
  # end

  private

  def populate_calendar(calendar_name, module_num)

  end

  def client_options
    {
      client_id: Rails.application.credentials.web[:client_id],
      client_secret: Rails.application.credentials.web[:client_secret],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    }
  end

  def get_module_lectures(module_number)
    # returns a hash with the day of the lecture as the key and the name of 
    # the lecture as the value.
    case module_number
    when 1
      {1 => "Hashketball Review",
       2 => "Hashes and the Internet",
       3 => "Intro to OO",
       4 => "Object Relations (one to many)",
       5 => "Object Relations (many to many)",
       8 => "SQL Review",
       9 => "Intro to ORMs",
       10 => "Dynamic ORMs",
       11 => "Intro to ActiveRecord",
       15 => "ActiveRecord Associations",
       18 => "Intro to Testing",
       19 => "Intro to the Internet"
      }
    when 2
      pass
    when 3
      pass
    when 4
      pass
    when 5
      pass
    else 
      "Module number must be an integer between 1 and 5, inclusive."
    end
  end

end