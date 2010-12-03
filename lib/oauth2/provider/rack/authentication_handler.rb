class OAuth2::Provider::Rack::AuthenticationHandler
  attr_reader :app, :env, :request, :mediator

  delegate :insufficient_scope?, :authentication_required?, :to => :mediator

  def initialize(app, env)
    @app = app
    @env = env
    @request = OAuth2::Provider::Rack::Request.new(env)
    @mediator = @env['oauth2'] = OAuth2::Provider::Rack::Mediator.new
  end

  def process
    if request.has_token?
      block_bad_request || block_invalid_token || app.call(env)
    else
      app.call(env)
    end
  end

  def block_bad_request
    if request.token_from_param && request.token_from_header
      json_error_response('invalid_request')
    end
  end

  def block_invalid_token
    access_token = OAuth2::Provider.access_token_class.find_by_access_token(request.token)
    mediator.access_grant = access_token.access_grant if access_token
    invalid_token(access_token) if access_token.nil? || access_token.expired?
  end

  def invalid_token(token)
    if token && token.expired? && token.refreshable?
      unauthorized 'expired_token'
    else
      unauthorized 'invalid_token'
    end
  end

  def json_error_response(error, options = {})
    [(options[:status] || 400), {'Content-Type' => 'application/json'}, [%{{"error": "#{error}"}}]]
  end

  def bad_request
    [400, {'Content-Type' => 'text/plain', 'Content-Length' => '0' }, []]
  end

  def unauthorized(error = nil)
    challenge = "OAuth realm='Application'"
    challenge << ", error='#{error}'" if error
    [401, {'Content-Type' => 'text/plain', 'Content-Length' => '0', 'WWW-Authenticate' => challenge}, []]
  end
end