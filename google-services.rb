class GoogleServices
  require 'google/apis/admin_directory_v1'
  require 'google-authorizer'
  require 'room'
  require 'pry'

  require 'fileutils'

  APPLICATION_NAME = 'Reptar'.freeze

  def initialize(user)
    @user = user
    @service = Google::Apis::AdminDirectoryV1::DirectoryService.new
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
    credentials = authorizer.send(code)
    @service.authorization = credentials
  end

  def room_available?(emoji)
    rooms = Room.new(@service.list_calendar_resources('my_customer').items, @user)

    !rooms.room_occupied?(emoji)
  end

  def room_events(emoji)
    rooms = Room.new(@service.list_calendar_resources('my_customer').items, @user)

    room = rooms.find_room(emoji)
    rooms.room_events(room.resource_email)
  end

  def find_rooms(options = {})
    rooms = Room.new(@service.list_calendar_resources('my_customer').items, @user)

    if options[:on].present?
      case options[:on]
      when '24'
        return rooms.on_twenty_four
      when '27'
        return rooms.on_twenty_seven
      end
    end

    rooms.by_name
    rooms.stripped_floor
  end

  private

  def authorizer
    @authorizer ||= GoogleAuthorizer.new(@user)
  end
end
