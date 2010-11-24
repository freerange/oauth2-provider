module OAuth2
  module Provider
    autoload :AuthenticationMiddleware, 'oauth2/provider/authentication_middleware'
    autoload :AuthorizationCodesSupport, 'oauth2/provider/authorization_codes_support'
    autoload :AccessTokensController, 'oauth2/provider/access_tokens_controller'
    autoload :Mediator, 'oauth2/provider/mediator'
    autoload :ControllerAuthentication, 'oauth2/provider/controller_authentication'
    autoload :Models, 'oauth2/provider/models'
    autoload :Random, 'oauth2/provider/random'
    autoload :TokenExpiry, 'oauth2/provider/token_expiry'

    mattr_accessor :backend
    self.backend = :active_record

    mattr_accessor :client_table_name
    self.client_table_name = 'oauth_clients'

    mattr_accessor :access_token_table_name
    self.access_token_table_name = 'oauth_access_tokens'

    mattr_accessor :authorization_code_table_name
    self.authorization_code_table_name = 'oauth_authorization_codes'

    mattr_accessor :access_grant_table_name
    self.access_grant_table_name = 'oauth_access_grants'

    mattr_accessor :access_grant_class_name
    self.access_grant_class_name = 'OAuth2::Provider::Models::ActiveRecord::AccessGrant'

    mattr_accessor :access_token_class_name
    self.access_token_class_name = 'OAuth2::Provider::Models::ActiveRecord::AccessToken'

    mattr_accessor :authorization_code_class_name
    self.authorization_code_class_name = 'OAuth2::Provider::Models::ActiveRecord::AuthorizationCode'

    mattr_accessor :client_class_name
    self.client_class_name = 'OAuth2::Provider::Models::ActiveRecord::Client'

    [:client, :access_grant, :access_token, :authorization_code].each do |model|
      instance_eval %{
        def #{model}_class
          #{model}_class_name.constantize
        end
      }
    end

    mattr_accessor :end_user_class_name
    self.end_user_class_name = 'Account'

    def self.end_user_class
      end_user_class_name.constantize
    end
  end
end