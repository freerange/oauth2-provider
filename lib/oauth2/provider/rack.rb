module OAuth2::Provider::Rack
  autoload :AccessTokenHandler, 'oauth2/provider/rack/access_token_handler'
  autoload :AuthenticationHandler, 'oauth2/provider/rack/authentication_handler'
  autoload :AuthenticationMediator, 'oauth2/provider/rack/authentication_mediator'
  autoload :AuthenticationResponses, 'oauth2/provider/rack/authentication_responses'
  autoload :AuthorizationCodeRequest, 'oauth2/provider/rack/authorization_code_request'
  autoload :Middleware, 'oauth2/provider/rack/middleware'
  autoload :Request, 'oauth2/provider/rack/request'
  autoload :ResourceRequest, 'oauth2/provider/rack/resource_request'
  autoload :Responses, 'oauth2/provider/rack/responses'
  autoload :AuthorizationCodesSupport, 'oauth2/provider/rack/authorization_codes_support'
  autoload :BearerTokenRequest, 'oauth2/provider/rack/bearer_token_request'

  class InvalidRequest < StandardError
  end
end