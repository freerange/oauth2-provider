module OAuth2::Provider::Rack
  class AuthorizationCodeRequest
    def initialize(params)
      @params = params
      validate!
    end

    def grant!(resource_owner = nil, authorization_expires_at = nil)
      grant_code!(resource_owner, authorization_expires_at) if response_type == 'code'
      grant_token!(resource_owner, authorization_expires_at) if response_type == 'token'
    end

    def grant_token!(resource_owner = nil, authorization_expires_at = nil)
      authorization = OAuth2::Provider.authorization_class.create!(
          :resource_owner => resource_owner,
          :client => client,
          :scope => scope
      )
      token = OAuth2::Provider.access_token_class.create!(
          :authorization => authorization,
          :expires_at => authorization_expires_at
      )
      throw_response Responses.redirect_with_hash_params(redirect_uri, token.as_json)
    end

    def grant_code!(resource_owner = nil, authorization_expires_at = nil)
      grant = client.authorizations.create!(
        :resource_owner => resource_owner,
        :client => client,
        :scope => scope,
        :expires_at => authorization_expires_at
      )
      code = grant.authorization_codes.create! :redirect_uri => redirect_uri
      throw_response Responses.redirect_with_code(code.code, redirect_uri)
    end

    def grant_existing!(resource_owner = nil)
      if existing = OAuth2::Provider.authorization_class.allowing(client, resource_owner, scope).first
        code = existing.authorization_codes.create! :redirect_uri => redirect_uri
        throw_response Responses.redirect_with_code(code.code, redirect_uri)
      end
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

    def response_type
      @params['response_type']
    end

    def client
      @client ||= OAuth2::Provider.client_class.from_param(client_id)
    end

    def redirect_uri
      @params['redirect_uri']
    end

    def response_type_valid?
      ['code', 'token'].include? response_type
    end

    def redirect_uri_valid?
      client && client.allow_redirection?(redirect_uri)
    end

    def scope
      @params['scope']
    end

    private

    def validate!
      unless response_type
        raise OAuth2::Provider::Rack::InvalidRequest, 'No response_type provided'
      end

      unless response_type_valid?
        raise OAuth2::Provider::Rack::InvalidRequest, 'response_type should be code/token'
      end

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

    def throw_response(response)
      throw :oauth2, response
    end
  end
end