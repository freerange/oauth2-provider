module OAuth2::Provider::Rack
  autoload :AccessTokenHandler, 'oauth2/provider/rack/access_token_handler'
  autoload :AuthenticationHandler, 'oauth2/provider/rack/authentication_handler'
  autoload :Mediator, 'oauth2/provider/rack/mediator'
  autoload :Middleware, 'oauth2/provider/rack/middleware'
  autoload :Request, 'oauth2/provider/rack/request'
  autoload :Responses, 'oauth2/provider/rack/responses'
end