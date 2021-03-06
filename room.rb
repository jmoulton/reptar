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

    events = room_events(room.resource_email)
    room = events.first

    booked?(room.start.date_time, room.end.date_time, Time.now)
  end

  def find_room(emoji)
    @rooms.find do |room|
      %r(#{emoji}).match(room.resource_name).present?
    end
  end

  def room_events(calendar_id)
    @calendar.fetch_most_recent_events(5, calendar_id)
  end

  def by_name
    @rooms.map!(&:resource_name)
  end

  def stripped_floor
    @rooms.each { |r| r[0..2] = '>' }
  end

  def booked?(start_time, end_time, current_time)
    start_time < current_time &&
      current_time < end_time
  end
end
