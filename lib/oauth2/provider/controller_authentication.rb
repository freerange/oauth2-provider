require 'oauth2/provider'

module OAuth2::Provider::ControllerAuthentication
  def authenticate_with_oauth
    if @oauth_access_token = OAuth2::Provider::AccessToken.find_by_access_token(oauth_token_from_request)
      if @oauth_access_token.expired?
        request_oauth_authentication 'invalid_token'
      end
    else
      request_oauth_authentication 'invalid_token'
    end
  end

  private

  def oauth_access_token
    @oauth_access_token
  end

  def oauth_token_from_request
    oauth_token_from_header || oauth_token_from_parameter
  end

  def oauth_token_from_parameter
    params[:oauth_token]
  end

  def oauth_token_from_header
    if request.headers["HTTP_AUTHORIZATION"] =~ /OAuth (.*)/
      $1
    end
  end

  def request_oauth_authentication(error, realm = 'Application')
    request.env['warden'] && request.env['warden'].custom_failure!
    response.headers["WWW-Authenticate"] = "OAuth realm='#{realm}', error='#{error}'"
    head :status => 401
  end
end