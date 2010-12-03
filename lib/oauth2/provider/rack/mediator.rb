module OAuth2::Provider::Rack
  class Mediator
    attr_reader :response
    attr_accessor :access_grant

    delegate :has_scope?, :to => :access_grant

    def authenticated?
      access_grant.present?
    end

    def authentication_required!
      @response = Responses.unauthorized
    end

    def insufficient_scope!
      @response = Responses.json_error 'insufficient_scope', :status => 403
    end
  end
end