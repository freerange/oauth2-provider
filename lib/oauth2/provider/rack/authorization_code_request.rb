module OAuth2::Provider::Rack
  class AuthorizationCodeRequest
    def initialize(env, params)
      @env = env
      @params = params
    end

    def validate!
      unless redirect_uri
        throw_response [400, {}, ['No redirect_uri provided']]
      end

      unless client_id
        throw_response Responses.redirect_with_error('invalid_request', redirect_uri)
      end

      unless client
        throw_response Responses.redirect_with_error('invalid_client', redirect_uri)
      end
    end

    def grant!(resource_owner = nil)
      grant = client.authorizations.create!(
        :resource_owner => resource_owner,
        :client => client
      )
      code = grant.authorization_codes.create! :redirect_uri => redirect_uri
      throw_response Responses.redirect_with_code(code.code, redirect_uri)
    end

    def deny!
      throw_response Responses.redirect_with_error('access_denied', redirect_uri)
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

    private

    def throw_response(response)
      @env['oauth2.response'] = response
      throw :oauth2
    end
  end
end