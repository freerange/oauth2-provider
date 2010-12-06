module OAuth2::Provider::Rack
  class Mediator
    attr_reader :response
    attr_accessor :access_grant

    delegate :has_scope?, :to => :access_grant

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

    def invalid_authorization_code_client!(uri)
      throw_response Responses.redirect_with_error('invalid_client', uri)
    end

    def invalid_authorization_code_request!(uri)
      throw_response Responses.redirect_with_error('invalid_request', uri)
    end

    def deny_authorization_code!(uri)
      throw_response Responses.redirect_with_error('access_denied', uri)
    end

    def grant_authorization_code!(uri, client, resource_owner)
      grant = client.access_grants.create!(
        :resource_owner => resource_owner,
        :client => client
      )
      code = grant.authorization_codes.create! :redirect_uri => uri
      throw_response Responses.redirect_with_code(code.code, uri)
    end

    private

    def throw_response(response)
      @response = response
      throw :oauth2
    end
  end
end