class Room

  def initialize(rooms)
    @rooms = rooms
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

  def by_name
    @rooms.map! { |r| r.resource_name }
  end

  def stripped_floor
    @rooms.each { |r| r[0..2] = '' }
  end
end
