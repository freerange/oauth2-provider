module OAuth2::Provider::Rack
  class AuthorizationCodeRequest
    def initialize(env, params)
      @env = env
      @params = params
    end

    def validate!
      unless client_id
        raise OAuth2::Provider::Rack::InvalidRequest, 'No client_id provided'
      end

      unless client
        raise OAuth2::Provider::Rack::InvalidRequest, 'client_id is invalid'
      end

      unless redirect_uri
        raise OAuth2::Provider::Rack::InvalidRequest, 'No redirect_uri provided'
      end

      unless redirect_uri_valid?
        raise OAuth2::Provider::Rack::InvalidRequest, 'Provided redirect_uri is invalid'
      end
    end

    def grant!(resource_owner = nil, authorization_expires_at = nil)
      grant = client.authorizations.create!(
        :resource_owner => resource_owner,
        :client => client,
        :scope => scope,
        :expires_at => authorization_expires_at
      )
      code = grant.authorization_codes.create! :redirect_uri => redirect_uri
      throw_response Responses.redirect_with_code(code.code, redirect_uri)
    end

    def deny!
      throw_response Responses.redirect_with_error('access_denied', redirect_uri)
    end

    def invalid_scope!
      throw_response Responses.redirect_with_error('invalid_scope', redirect_uri)
    end

    def client_id
      @params['client_id']
    end

    def client
      @client ||= OAuth2::Provider.client_class.from_param(client_id)
    end

    def redirect_uri
      @params['redirect_uri']
    end

    def redirect_uri_valid?
      provided_host = Addressable::URI.parse(redirect_uri).host
      unless client.oauth_redirect_uri.nil?
        client_host = Addressable::URI.parse(client.oauth_redirect_uri).host
        client_host == provided_host
      else
        true
      end
    rescue
      nil
    end

    def scope
      @params['scope']
    end

    private

    def throw_response(response)
      throw :oauth2, response
    end
  end
end