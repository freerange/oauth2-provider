require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

class OAuth2::Provider::AuthenticationMiddleware < Rack::Auth::AbstractHandler
  def initialize(app, config = nil)
    @app = app
  end

  def call(env)
    @env = env
    if request.token_from_header.nil? && request.token_from_param.nil?
      oauth2
      @app.call(env)
    elsif request.token_from_header && request.token_from_param
      bad_request
    elsif oauth2.access_token = OAuth2::Provider::AccessToken.find_by_access_token(request.token_from_header || request.token_from_param)
      if oauth2.access_token.expired?
        if oauth2.access_token.refreshable?
          request_oauth_authentication 'expired_token'
        else
          request_oauth_authentication 'invalid_token'
        end
      else
        @app.call(env)
      end
    else
      request_oauth_authentication 'invalid_token'
    end
  end

  def request_oauth_authentication(error = nil)
    challenge = "OAuth realm='Application'"
    challenge << ", error='#{error}'" if error
    unauthorized challenge
  end

  def oauth2
    @env['oauth2'] ||= OAuth2::Provider::Core.new
  end

  def request
    request = Request.new(@env)
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