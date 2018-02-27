require 'google_calendar'

module CalendarBot
  class Calendar < SlackRubyBot::Commands::Base
    command 'list my calendar events' do |client, data, _match|
      calendar = self.calendar
      calendar.authorize

      events = calendar.fetch_most_recent_events
      client.say(channel: data.channel, text: events)
    end

    def self.calendar
      GoogleCalendar.new
    end
  end
end
