require 'oauth2/provider'

module OAuth2::Provider::Rails::ControllerAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticate_with_oauth(options = {})
      around_filter AuthenticationFilter.new(options.delete(:scope)), options
    end

    class AuthenticationFilter
      def initialize(scope = nil)
        @scope = scope
      end

      def filter(controller, &block)
        oauth2 = controller.request.env['oauth2']

        if oauth2.authenticated?
          if @scope.nil? || oauth2.has_scope?(@scope)
            yield
          else
            oauth2.insufficient_scope!
          end
        else
          oauth2.authentication_required!
        end
      end
    end
  end
end