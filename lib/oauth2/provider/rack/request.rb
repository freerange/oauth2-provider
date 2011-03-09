require 'rack/auth/abstract/request'

class OAuth2::Provider::Rack::Request < Rack::Request
  def access_token_path?
    path == "/oauth/access_token"
  end

  def grant_type
    params["grant_type"]
  end
end
