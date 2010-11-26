module OAuth2::Provider::Models::Shared
  autoload :AccessGrant, 'oauth2/provider/models/shared/access_grant'
  autoload :AccessToken, 'oauth2/provider/models/shared/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/shared/authorization_code'
  autoload :Client, 'oauth2/provider/models/shared/client'
  autoload :TokenExpiry, 'oauth2/provider/models/shared/token_expiry'
end