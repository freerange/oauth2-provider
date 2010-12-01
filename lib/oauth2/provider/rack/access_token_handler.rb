class OAuth2::Provider::Rack::AccessTokenHandler
  attr_reader :app, :env, :request

  def initialize(app, env)
    @app = app
    @env = env
    @request = OAuth2::Provider::Rack::Request.new(env)
  end

  def response
    if request.for_access_token?
      block_unsupported_grant_types || block_invalid_clients || handle_grant_type
    else
      app.call(env)
    end
  end

  def handle_grant_type
    send "handle_#{request.grant_type}_grant_type"
  end

  def handle_password_grant_type
    with_required_params 'username', 'password' do |username, password|
      if account = OAuth2::Provider.end_user_class.authenticate_with_username_and_password(username, password)
        token_response OAuth2::Provider.access_token_class.create!(
          :access_grant => OAuth2::Provider.access_grant_class.create!(:account => account, :client => oauth_client)
        )
      else
        json_error_response 'invalid_grant'
      end
    end
  end

  def handle_authorization_code_grant_type
    with_required_params 'code', 'redirect_uri' do |code, redirect_uri|
      if token = oauth_client.authorization_codes.claim(code, redirect_uri)
        token_response token
      else
        json_error_response 'invalid_grant'
      end
    end
  end

  def handle_refresh_token_grant_type
    with_required_params 'refresh_token' do |refresh_token|
      if token = oauth_client.access_tokens.refresh_with(refresh_token)
        token_response token
      else
        json_error_response 'invalid_grant'
      end
    end
  end

  def with_required_params(*names, &block)
    values = request.params.values_at(*names)
    if values.include?(nil)
      json_error_response 'invalid_request'
    else
      yield *values
    end
  end

  def json_error_response(error, options = {})
    [400, {'Content-Type' => 'application/json'}, [%{{"error": "#{error}"}}]]
  end

  def token_response(token)
    json = token.as_json.tap do |json|
      json[:state] = request.params['state'] if request.params['state']
    end
    [200, {'Content-Type' => 'application/json', 'Cache-Control' => 'no-cache, no-store, max-age=0, must-revalidate'}, [ActiveSupport::JSON.encode(json)]]
  end

  def block_unsupported_grant_types
    with_required_params 'grant_type' do |grant_type|
      unless respond_to?("handle_#{grant_type}_grant_type", true)
        json_error_response 'unsupported_grant_type'
      end
    end
  end

  def block_invalid_clients
    with_required_params 'grant_type', 'client_id', 'client_secret' do |grant_type, client_id, client_secret|
      @oauth_client = OAuth2::Provider.client_class.find_by_oauth_identifier_and_oauth_secret(client_id, client_secret)
      if @oauth_client.nil?
        json_error_response 'invalid_client'
      elsif !@oauth_client.allow_grant_type?(grant_type)
        json_error_response 'unauthorized_client'
      end
    end
  end

  def oauth_client
    @oauth_client
  end
end