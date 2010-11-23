require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

class OAuth2::Provider::AuthenticationMiddleware < Rack::Auth::AbstractHandler
  def initialize(app, config = nil)
    @app = app
  end

  def call(env)
    Handler.new(@app, env).response
  end

  class Handler
    attr_reader :app, :env, :request

    delegate :access_token, :access_token=, :to => :mediator

    def initialize(app, env)
      @app = app
      @env = env
      @request = Request.new(env)
      @env['oauth2'] = OAuth2::Provider::Mediator.new
    end

    def mediator
      @env['oauth2']
    end

    def response
      if request.has_token?
        block_bad_request || block_invalid_tokens || handle_request
      else
        result = app.call(env)
        force_authentication || result
      end
    end

    def handle_request
      result = app.call(env)
      force_insufficient_scope || result
    end

    def block_bad_request
      if request.token_from_param && request.token_from_header
        bad_request
      end
    end

    def block_invalid_tokens
      self.access_token = OAuth2::Provider::AccessToken.find_by_access_token(request.token)
      invalid_token(access_token) if access_token.nil? || access_token.expired?
    end

    def force_authentication
      unauthorized if @env['oauth2'].authentication_required?
    end

    def force_insufficient_scope
      forbidden if @env['oauth2'].insufficient_scope?
    end

    def invalid_token(token)
      if token && token.expired? && token.refreshable?
        unauthorized 'expired_token'
      else
        unauthorized 'invalid_token'
      end
    end

    def forbidden
      [403, {'Content-Type' => 'text/plain', 'Content-Length' => '0'}, []]
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

  class Request < Rack::Request
    def token
      token_from_param || token_from_header
    end

    def has_token?
      !token.nil?
    end

    def token_from_param
      params["oauth_token"]
    end

    def token_from_header
      if @env[authorization_key] =~ /OAuth (.*)/
        $1
      end
    end

    def authorization_key
      @authorization_key ||= Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.detect do |key|
        @env.has_key?(key)
      end
    end
  end
end