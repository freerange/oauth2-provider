module OAuth2::Provider::Rack
  class AuthenticationMediator
    attr_reader :response
    attr_accessor :authorization

    delegate :has_scope?, :to => :authorization

    def initialize(env)
      @env = env
    end

    def authenticated?
      authorization.present?
    end

    def resource_owner
      authorization && authorization.resource_owner
    end

    def authentication_required!
      throw_response Responses.unauthorized
    end

    def insufficient_scope!
      throw_response Responses.json_error('insufficient_scope', :status => 403)
    end

    private

    def throw_response(response)
      @env['oauth2.response'] = response
      throw :oauth2
    end
  end
end