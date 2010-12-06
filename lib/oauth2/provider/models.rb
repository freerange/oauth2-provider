module OAuth2::Provider::Models
  autoload :ActiveRecord, 'oauth2/provider/models/active_record'
  autoload :Mongoid, 'oauth2/provider/models/mongoid'

  autoload :AccessGrant, 'oauth2/provider/models/access_grant'
  autoload :AccessToken, 'oauth2/provider/models/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/authorization_code'
  autoload :Client, 'oauth2/provider/models/client'

  module TokenExpiry
    def expired?
      self.expires_at && self.expires_at < Time.now
    end

    def expires_in
      if expired?
        0
      else
        self.expires_at.to_i - Time.now.to_i
      end
    end
  end
end