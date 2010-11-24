module OAuth2::Provider::Models::ActiveRecord
  autoload :AccessGrant, 'oauth2/provider/models/active_record/access_grant'
  autoload :AccessToken, 'oauth2/provider/models/active_record/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/active_record/authorization_code'
  autoload :Client, 'oauth2/provider/models/active_record/client'
end