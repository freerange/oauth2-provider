module OAuth2
  module Provider
    autoload :Rails, 'oauth2/provider/rails'
    autoload :Models, 'oauth2/provider/models'
    autoload :Random, 'oauth2/provider/random'
    autoload :Rack, 'oauth2/provider/rack'

    mattr_accessor :backend
    self.backend = :active_record

    mattr_accessor :access_grant_class_name
    mattr_accessor :access_token_class_name
    mattr_accessor :authorization_code_class_name
    mattr_accessor :client_class_name

    [:resource_owner, :client, :access_grant, :access_token, :authorization_code].each do |model|
      instance_eval %{
        def #{model}_class
          #{model}_class_name.constantize
        end
      }
    end

    mattr_accessor :resource_owner_class_name
    self.resource_owner_class_name = 'ExampleResourceOwner'

    def self.configure
      yield self
    end

    def self.backend=(backend)
      @@backend = backend
      case backend
        when :mongoid then OAuth2::Provider::Models::Mongoid.activate
        else OAuth2::Provider::Models::ActiveRecord.activate
      end
    end
  end
end