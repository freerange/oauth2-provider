require 'oauth2/provider'

class OAuth2::Provider::Railtie < Rails::Railtie
  config.oauth2_provider = ActiveSupport::OrderedOptions.new

  initializer "oauth2_provider.config" do |app|
    app.config.oauth2_provider.each do |k,v|
      OAuth2::Provider.send "#{k}=", v
    end

    case OAuth2::Provider.backend
      when :mongoid then OAuth2::Provider::Models::Mongoid.activate
      else OAuth2::Provider::Models::ActiveRecord.activate
    end
  end

  initializer "oauth2_provider controller" do |app|
    ActionController::Base.module_eval do
      include OAuth2::Provider::ControllerAuthentication
    end
  end

  initializer "middleware ho!" do |app|
    app.middleware.use ::OAuth2::Provider::AuthenticationMiddleware
  end
end