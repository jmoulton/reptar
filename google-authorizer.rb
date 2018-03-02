class GoogleAuthorizer
  require 'google/apis/admin_directory_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'calendar-bot/commands/calendar'
  require 'pry'

  require 'fileutils'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
  CLIENT_SECRETS_PATH = 'client_secret.json'.freeze
  SCOPE = [Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
           Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_RESOURCE_CALENDAR].freeze

  def initialize(user)
    @user = user
    make_dir
    @client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    @token_store = Google::Auth::Stores::FileTokenStore.new(file: user_credential_path)
  end

  ## Ensure valid credentials, either by restoring from the saved credentials
  ## files or intitiating an OAuth2 authorization. If authorization is required,
  ## the user's default browser will be launched to approve the request.
  ## @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    @credentials = authorizer.get_credentials(user_id)
    if @credentials.nil? || @credentials.expired?
      raise CalendarBot::AuthorizationError
    end

    @credentials
  end

  def authorize_me!
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
    @credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)

    @credentials
  end

  private

  def user_id
    'default'
  end

  def make_dir
    FileUtils.mkdir_p(File.dirname(user_credential_path))
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new(@client_id,
                                                     SCOPE,
                                                     @token_store)
  end

  def user_credential_path
    @path ||= File.join(Dir.home, '.credentials', "#{@user}_credentials.yaml")
  end
end
