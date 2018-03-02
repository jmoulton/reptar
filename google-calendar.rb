class GoogleCalendar
  require 'google/apis/calendar_v3'
  require 'google-authorizer'
  require 'pry'

  APPLICATION_NAME = 'Reptar'.freeze

  def initialize(user)
    @user = user
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
  end

  def authorize
    credentials = authorizer.authorize
    @service.authorization = credentials
  end

  def authorize_me!
    authorizer.authorize_me!
  end

  def send_code(code)
    credentials = authorizer.send_code(code)
    @service.authorization = credentials
  end

  def fetch_most_recent_events(count = 10, calendar_id = 'primary')
    response = @service.list_events(calendar_id,
                                    max_results: count,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: Time.now.iso8601)

    return 'No upcoming events found' if response.items.empty?

    response.items
  end

  def format!(events)
    str = ''
    events.each do |event|
      start = event.start.date_time
      start = start.strftime('from %I:%M%p to ')
      end_time = event.end.date_time
      end_time = end_time.strftime('%I:%M%p on %m/%d/%Y')

      summary = event.summary.present? ? event.summary : 'Meeting'
      str += "> *#{summary}* #{start}#{end_time}\n"
    end

    str
  end

  private

  def authorizer
    @authorizer ||= GoogleAuthorizer.new(@user)
  end
end
