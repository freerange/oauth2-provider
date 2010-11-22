module OAuth2
  module Provider
    autoload :AuthorizationCode, 'oauth2/provider/authorization_code'
    autoload :AuthorizationCodesSupport, 'oauth2/provider/authorization_codes_support'
    autoload :AccessToken, 'oauth2/provider/access_token'
    autoload :AccessTokensController, 'oauth2/provider/access_tokens_controller'
    autoload :Client, 'oauth2/provider/client'
    autoload :ControllerAuthentication, 'oauth2/provider/controller_authentication'
    autoload :Random, 'oauth2/provider/random'
    autoload :TokenExpiry, 'oauth2/provider/token_expiry'
    autoload :TokenRoles, 'oauth2/provider/token_roles'

    mattr_accessor :client_table_name
    self.client_table_name = 'oauth_clients'

    mattr_accessor :access_token_table_name
    self.access_token_table_name = 'oauth_access_tokens'

    mattr_accessor :authorization_code_table_name
    self.authorization_code_table_name = 'oauth_authorization_codes'

    mattr_accessor :client_class_name
    self.client_class_name = "OAuth2::Provider::Client"

    def self.client_class
      client_class_name.constantize
    end

    mattr_accessor :end_user_class_name
    self.end_user_class_name = 'Account'

    def self.end_user_class
      end_user_class_name.constantize
    end
  end
end