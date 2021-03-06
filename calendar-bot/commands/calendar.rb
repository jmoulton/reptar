require 'google-calendar'
require 'google-authorizer'
require 'google-services'
require 'constants'

module CalendarBot
  class Calendar < SlackRubyBot::Commands::Base

    command 'authorize me!' do |client, data, _match|
      calendar = self.calendar(data['user'])
      url = calendar.authorize_me!

      client.say(channel: data.channel, text: url)
    end

    command 'list my calendar events' do |client, data, _match|
      with_auth(client, data) do
        calendar = self.calendar(data['user'])
        calendar.authorize

        events = calendar.fetch_most_recent_events
        events = calendar.format!(events)

        client.say(channel: data.channel, text: events)
      end
    end

    command "what's my next event?" do |client, data, _match|
      with_auth(client, data) do
        calendar = self.calendar(data['user'])
        calendar.authorize

        events = calendar.fetch_most_recent_events(1)
        events = calendar.format!(events)

        text = ":yodawg: Looks like your next event is:\n#{events}"
        client.say(channel: data.channel, text: text)
      end
    end

    command(/list rooms/, /list rooms on 24/, /list rooms on 27/,
            /list open rooms on 24/, /list open rooms on 27/)  do |client, data, match|
      with_auth(client, data) do
        service = GoogleServices.new(data['user'])
        service.authorize

        opts = {}
        command = match.to_s
        opts[:on] = '24' if /24/.match(command).present?
        opts[:on] = '27' if /27/.match(command).present?
        rooms = service.find_rooms(opts)

        text = "#{Constants::ROOMS.sample(1).first}\n#{rooms.join("\n")}"

        client.say(channel: data.channel, text: text)
      end
    end

    command(/is\s\:.+\:\savailable\?/) do |client, data, match|
      with_auth(client, data) do
        service = GoogleServices.new(data['user'])
        service.authorize

        emoji = match.to_s.scan(/\:.+\:/).first
        available = service.room_available?(emoji)

        if available
          text = ':ohyeah: looks like that room is free! :dancing:'
        else
          events = calendar(data['user']).format!(service.room_events(emoji))
          text = "Bummer :dude:! Looks like it's booked. Here are the upcoming events:\n#{events}"
        end

        client.say(channel: data.channel, text: text)
      end
    end

    command /list events in \:.+\:/ do |client, data, match|
      service = GoogleServices.new(data['user'])
      service.authorize

      emoji = match.to_s.scan(/\:.+\:/).first

      events = calendar(data['user']).format!(service.room_events(emoji))

      text = ":ohmy: here are the upcoming event times in #{emoji}\n#{events}"

      client.say(channel: data.channel, text: text)
    end

    command 'who is reptar?' do |client, data, _match|
      client.say(channel: data.channel, text: "https://www.youtube.com/watch?v=kLCmiVs_j7Y")
    end

    match /\d{1}\/.+/ do |client, data, _match|
      calendar(data['user']).send_code(data["text"])

      client.say(channel: data.channel, text: "Groovy! All set!")
    end

    def self.calendar(user)
      GoogleCalendar.new(user)
    end

    def self.with_auth(client, data)
      yield
    rescue AuthorizationError
      text = "Oops! Looks like you're not authenticated. Try telling me: \"authorize me!\""
      client.say(channel: data.channel, text: text)
    end
  end

  class AuthorizationError < StandardError
  end
end
