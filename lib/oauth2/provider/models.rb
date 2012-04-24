module OAuth2::Provider::Models
  autoload :ActiveRecord, 'oauth2/provider/models/active_record'
  autoload :Mongoid, 'oauth2/provider/models/mongoid'

  autoload :Authorization, 'oauth2/provider/models/authorization'
  autoload :AccessToken, 'oauth2/provider/models/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/authorization_code'
  autoload :Client, 'oauth2/provider/models/client'

  module TokenExpiry
    extend ActiveSupport::Concern

    included do
      mattr_accessor :default_token_lifespan
    end

    def initialize(attributes = {}, *args, &block)
      attributes ||= {}
      if default_token_lifespan
        attributes = attributes.reverse_merge(:expires_at => default_token_lifespan.from_now)
      end
      super
    end

    def fresh?
      !expired?
    end

    def expired?
      self.expires_at && self.expires_at < Time.now
    end

    def expires_in
      if expired?
        0
      else
        self.expires_at && self.expires_at.to_i - Time.now.to_i
      end
    end
  end

  module RandomToken
    extend ActiveSupport::Concern

    module ClassMethods
      def random_token
        OAuth2::Provider::Random.base62(48)
      end

      def unique_random_token(attribute)
        key = random_token while (key.nil? || where(attribute => key).exists?)
        key
      end
    end
  end
end