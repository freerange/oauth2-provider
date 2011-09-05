require 'rack/auth/abstract/request'

module OAuth2::Provider::Rack
  class BearerTokenRequest < Rack::Request
    class_attribute :parameter_name
    self.parameter_name = "access_token"

    class_attribute :authorization_scheme_name
    self.authorization_scheme_name = "Bearer"

    def access_token
      access_token_from_param || access_token_from_header
    end

    def has_access_token?
      !access_token.nil?
    end

    def access_token_from_param
      params[self.class.parameter_name]
    end

    def access_token_from_header
      if authorization_header.provided?
        if authorization_header.scheme == authorization_scheme_name.downcase.to_sym
          authorization_header.params
        end
      end
    end

    def validate_access_token!
      multiple_tokens! if access_token_from_param && access_token_from_header
      invalid_token! if token_instance.nil?
      expired_token! if access_token_expired?
    end

    private

    def access_token_expired?
      token_instance && token_instance.expired?
    end

    def multiple_tokens!
      invalid_request! 'Access token provided as both header and parameter'
    end

    def expired_token!
      invalid_token! 'Access token has expired'
    end

    def authorization_header
      @authorization_header ||= Rack::Auth::AbstractRequest.new(@env)
    end

    def token_instance
      @token_instance ||= OAuth2::Provider.access_token_class.find_by_access_token(access_token)
    end
  end
end