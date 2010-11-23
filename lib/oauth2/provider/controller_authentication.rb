require 'oauth2/provider'

module OAuth2::Provider::ControllerAuthentication
  extend ActiveSupport::Concern

  private

  def oauth2
    request.env['oauth2']
  end

  def authenticate_oauth_token

  end

  def block_bad_oauth_requests

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
      scope = options.delete(:scope)

      before_filter options do
        if oauth_token_from_parameter && oauth_token_from_header
          request_oauth_authentication('invalid_request', 400)
        elsif !oauth_token_from_parameter && !oauth_token_from_header
          request_oauth_authentication
        end
      end

      before_filter options do
        if oauth2.access_token = OAuth2::Provider::AccessToken.find_by_access_token(oauth_token_from_parameter || oauth_token_from_header)
          if oauth2.access_token.expired?
            if oauth2.access_token.refreshable?
              request_oauth_authentication 'expired_token'
            else
              request_oauth_authentication 'invalid_token'
            end
          end
        else
          request_oauth_authentication 'invalid_token'
        end
      end

      if scope
        before_filter options do
          unless oauth2.access_token.has_scope?(scope)
            request_oauth_authentication('insufficient_scope', status = 403)
          end
        end
      end
    end
  end
end