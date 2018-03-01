class Room
  require 'google-calendar'

  def initialize(rooms, user)
    @rooms = rooms
    @calendar = GoogleCalendar.new(user)
    @calendar.authorize
  end

  def on_twenty_four
    by_name

    @rooms.select! do |room|
      /24/.match(room).present?
    end

    stripped_floor
  end

  def on_twenty_seven
    by_name

    @rooms.select! do |room|
      /27/.match(room).present?
    end

    stripped_floor
  end

  def room_occupied?(emoji)
    room = find_room(emoji)
    return false unless room.present?

    calendar_id = room.resource_email
    room = find_room(emoji)

    events = room_events(room.resource_email)
    room = events.first

    room.start.date_time.to_time.utc < (Time.now + 3.hours).utc &&
      (Time.now + 3.hours).utc < room.end.date_time.to_time.utc
  end

  def find_room(emoji)
    @rooms.find do |room|
      %r(#{emoji}).match(room.resource_name).present?
    end
  end

  def room_events(calendar_id)
    @calendar.fetch_most_recent_events(10, calendar_id)
  end

  def by_name
    @rooms.map! { |r| r.resource_name }
  end

  def stripped_floor
    @rooms.each { |r| r[0..2] = '' }
  end
end
