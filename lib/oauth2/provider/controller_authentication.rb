require 'oauth2/provider'

module OAuth2::Provider::ControllerAuthentication
  extend ActiveSupport::Concern

  private

  def authenticate_oauth_token
    if @oauth_access_token = OAuth2::Provider::AccessToken.find_by_access_token(oauth_token_from_parameter || oauth_token_from_header)
      if @oauth_access_token.expired?
        request_oauth_authentication 'invalid_token'
      end
    else
      request_oauth_authentication 'invalid_token'
    end
  end

  def block_bad_oauth_requests
    if oauth_token_from_parameter && oauth_token_from_header
      request_oauth_authentication('invalid_request', 400)
    elsif !oauth_token_from_parameter && !oauth_token_from_header
      request_oauth_authentication
    end
  end

  def oauth_access_token
    @oauth_access_token
  end

  def oauth_token_from_parameter
    params[:oauth_token]
  end

  def oauth_token_from_header
    if request.headers["HTTP_AUTHORIZATION"] =~ /OAuth (.*)/
      $1
    end
  end

  def request_oauth_authentication(error = nil, status = 401)
    request.env['warden'] && request.env['warden'].custom_failure!
    response.headers["WWW-Authenticate"] = "OAuth realm='Application'"
    response.headers["WWW-Authenticate"] << ", error='#{error}'" if error
    head :status => status
  end

  module ClassMethods
    def authenticate_with_oauth(options = {})
      before_filter :block_bad_oauth_requests, options
      before_filter :authenticate_oauth_token, options
    end
  end
end