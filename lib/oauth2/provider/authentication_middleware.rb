require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

class OAuth2::Provider::AuthenticationMiddleware < Rack::Auth::AbstractHandler
  def initialize(app, config = nil)
    @app = app
  end

  def call(env)
    request = Request.new(env)

    if request.token_from_header && request.token_from_param
      bad_request
    else
      env['oauth2'] = OAuth2::Provider::Core.new
      @app.call(env)
    end
  end

  class Request < Rack::Request
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