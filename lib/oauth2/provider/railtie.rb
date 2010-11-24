require 'oauth2/provider'

class OAuth2::Provider::Railtie < Rails::Railtie
  config.oauth2_provider = ActiveSupport::OrderedOptions.new

  initializer "oauth2_provider.config" do |app|
    app.config.oauth2_provider.each do |k,v|
      OAuth2::Provider.send "#{k}=", v
    end
  end

  initializer "oauth2_provider controller" do |app|
    ActionController::Base.module_eval do
      include OAuth2::Provider::ControllerAuthentication
    end
  end

  initializer "oauth2_provider models" do |app|
    OAuth2::Provider::Models::ActiveRecord::Client.set_table_name OAuth2::Provider.client_table_name
    OAuth2::Provider::Models::ActiveRecord::AccessToken.set_table_name OAuth2::Provider.access_token_table_name
    OAuth2::Provider::Models::ActiveRecord::AuthorizationCode.set_table_name OAuth2::Provider.authorization_code_table_name
    OAuth2::Provider::Models::ActiveRecord::AccessGrant.set_table_name OAuth2::Provider.access_grant_table_name
  end

  initializer "middleware ho!" do |app|
    app.middleware.use ::OAuth2::Provider::AuthenticationMiddleware
  end
end