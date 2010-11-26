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