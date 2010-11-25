module OAuth2::Provider::Models::Mongoid
  autoload :AccessGrant, 'oauth2/provider/models/mongoid/access_grant'
  autoload :AccessToken, 'oauth2/provider/models/mongoid/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/mongoid/authorization_code'
  autoload :Client, 'oauth2/provider/models/mongoid/client'

  def self.activate(options = {})
    OAuth2::Provider.client_class_name ||= "OAuth2::Provider::Models::Mongoid::Client"
    OAuth2::Provider.access_token_class_name ||= "OAuth2::Provider::Models::Mongoid::AccessToken"
    OAuth2::Provider.authorization_code_class_name ||= "OAuth2::Provider::Models::Mongoid::AuthorizationCode"
    OAuth2::Provider.access_grant_class_name ||= "OAuth2::Provider::Models::Mongoid::AccessGrant"
  end
end