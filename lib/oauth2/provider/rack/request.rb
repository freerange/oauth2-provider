require 'rack/auth/abstract/request'

class OAuth2::Provider::Rack::Request < Rack::Request
  def access_token_path?
    path == "/oauth/access_token"
  end

  def grant_type
    params["grant_type"]
  end

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