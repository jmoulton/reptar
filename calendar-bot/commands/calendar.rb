require 'google_calendar'

module CalendarBot
  class Calendar < SlackRubyBot::Commands::Base
    command 'list my calendar events' do |client, data, _match|
      begin
        calendar = self.calendar(data['user'])
        calendar.authorize

        events = calendar.fetch_most_recent_events
        client.say(channel: data.channel, text: events)
      rescue AuthorizationError
        text = "Oops! Looks like you're not authenticated. Try telling me: 'authorize me!'"
        client.say(channel: data.channel, text: text)
      end
    end

    command 'authorize me!' do |client, data, _match|
      calendar = self.calendar(data['user'])
      url = calendar.authorize_me!

      client.say(channel: data.channel, text: url)
    end

    match /\d{1}\/.+/ do |client, data, _match|
      calendar(data['user']).send_code(data["text"])

      client.say(channel: data.channel, text: "Groovy! All set!")
    end

    def self.calendar(user)
      GoogleCalendar.new(user)
    end
  end

  class AuthorizationError < StandardError
  end
end
