module OAuth2::Provider::Models::ActiveRecord
  autoload :AccessGrant, 'oauth2/provider/models/active_record/access_grant'
  autoload :AccessToken, 'oauth2/provider/models/active_record/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/active_record/authorization_code'
  autoload :Client, 'oauth2/provider/models/active_record/client'

  mattr_accessor :client_table_name
  self.client_table_name = 'oauth_clients'

  mattr_accessor :access_token_table_name
  self.access_token_table_name = 'oauth_access_tokens'

  mattr_accessor :authorization_code_table_name
  self.authorization_code_table_name = 'oauth_authorization_codes'

  mattr_accessor :access_grant_table_name
  self.access_grant_table_name = 'oauth_access_grants'

  def self.activate(options = {})
    OAuth2::Provider.client_class_name ||= "OAuth2::Provider::Models::ActiveRecord::Client"
    OAuth2::Provider.access_token_class_name ||= "OAuth2::Provider::Models::ActiveRecord::AccessToken"
    OAuth2::Provider.authorization_code_class_name ||= "OAuth2::Provider::Models::ActiveRecord::AuthorizationCode"
    OAuth2::Provider.access_grant_class_name ||= "OAuth2::Provider::Models::ActiveRecord::AccessGrant"

    OAuth2::Provider.client_class.set_table_name client_table_name
    OAuth2::Provider.access_token_class.set_table_name access_token_table_name
    OAuth2::Provider.authorization_code_class.set_table_name authorization_code_table_name
    OAuth2::Provider.access_grant_class.set_table_name access_grant_table_name
  end
end