require 'oauth2/provider'

module OAuth2::Provider::ControllerAuthentication
  extend ActiveSupport::Concern

  private

  def oauth2
    request.env['oauth2']
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

      around_filter AuthenticationFilter.new(scope), options

      if scope
        before_filter options do
          unless oauth2.access_token.has_scope?(scope)
            request_oauth_authentication('insufficient_scope', status = 403)
          end
        end
      end
    end

    class AuthenticationFilter
      def initialize(scope = nil)
        @scope = scope
      end

      def filter(controller, &block)
        oauth2 = controller.request.env['oauth2']
        if oauth2.authenticated?
          yield
        else
          oauth2.authentication_required!
        end
      end
    end
  end
end