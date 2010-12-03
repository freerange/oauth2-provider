require 'oauth2/provider'

module OAuth2::Provider::Rails
  autoload :ControllerAuthentication, 'oauth2/provider/rails/controller_authentication'
  autoload :AuthorizationCodesSupport, 'oauth2/provider/rails/authorization_codes_support'
  
  class Railtie < Rails::Railtie
    config.oauth2_provider = ActiveSupport::OrderedOptions.new
    config.oauth2_provider.active_record = ActiveSupport::OrderedOptions.new
    config.oauth2_provider.mongoid = ActiveSupport::OrderedOptions.new

    initializer "oauth2_provider.config" do |app|
      app.config.oauth2_provider.except(:active_record, :mongoid).each do |k,v|
        OAuth2::Provider.send "#{k}=", v
      end

      app.config.oauth2_provider.active_record.each do |k, v|
        OAuth2::Provider::Models::ActiveRecord.send "#{k}=", v
      end

      app.config.oauth2_provider.mongoid.each do |k, v|
        OAuth2::Provider::Models::Mongoid.send "#{k}=", v
      end

      case OAuth2::Provider.backend
        when :mongoid then OAuth2::Provider::Models::Mongoid.activate
        else OAuth2::Provider::Models::ActiveRecord.activate
      end
    end

    initializer "oauth2_provider controller" do |app|
      ActionController::Base.module_eval do
        include OAuth2::Provider::Rails::ControllerAuthentication
      end
    end

    initializer "middleware ho!" do |app|
      app.middleware.use ::OAuth2::Provider::Rack::Middleware
    end
  end
end