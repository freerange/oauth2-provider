module OAuth2::Provider::Rack
  class AuthenticationMediator
    attr_reader :response
    attr_accessor :access_grant

    delegate :has_scope?, :to => :access_grant

    def initialize(env)
      @env = env
    end

    def authenticated?
      access_grant.present?
    end

    def resource_owner
      access_grant && access_grant.resource_owner
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