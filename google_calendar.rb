class GoogleCalendar
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'calendar-bot/commands/calendar'
  require 'pry'

  require 'fileutils'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  def initialize(user)
    @user = user
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
  end

  ##
  ## Ensure valid credentials, either by restoring from the saved credentials
  ## files or intitiating an OAuth2 authorization. If authorization is required,
  ## the user's default browser will be launched to approve the request.
  ##
  ## @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(user_credential_path))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: user_credential_path)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    @credentials = authorizer.get_credentials(user_id)
    if @credentials.nil? || @credentials.expired?
      raise CalendarBot::AuthorizationError
    end
    @service.authorization = @credentials
  end

  def authorize_me!
    FileUtils.mkdir_p(File.dirname(user_credential_path))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: user_credential_path)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    @credentials = authorizer.get_credentials(user_id)
    if @credentials.nil? || @credentials.expired?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
    else
      @service.authorization = @credentials
    end

    text = "Enter this url into your browser: #{url} then paste the code back to me"

    url.nil? ? "Looks like you're good to go!" : text
  end

  def send_code(code)
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: user_credential_path)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'

    @credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)

    @service.authorization = @credentials
  end

  def fetch_most_recent_events(count = 10)
    calendar_id = 'primary'
    response = @service.list_events(calendar_id,
                                   max_results: count,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_min: Time.now.iso8601)

    return "No upcoming events found" if response.items.empty?
    str = "";
    response.items.each do |event|
      start = event.start.date || event.start.date_time
      str = str + "- #{event.summary} (#{start})\n"
    end

    return str
  end

  private

  def user_credential_path
    @path ||= File.join(Dir.home, '.credentials', "#{@user}_credentials.yaml")
  end
end
