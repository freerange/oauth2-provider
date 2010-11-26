module OAuth2::Provider::Rack
  autoload :AccessTokenMiddleware, 'oauth2/provider/rack/access_token_middleware'
  autoload :AuthenticationMiddleware, 'oauth2/provider/rack/authentication_middleware'
  autoload :Mediator, 'oauth2/provider/rack/mediator'
end