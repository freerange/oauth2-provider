module OAuth2::Provider::Models::AuthorizationCode
  extend ActiveSupport::Concern

  # How long an authorization code is good for. Defaults to 1 minute, set this
  # if you want something different.  Example (for a Rails app place this
  # line of code in a file in config/initializers):
  # OAuth2::Provider::Models::AuthorizationCode.code_lifespan = 30.seconds
  mattr_accessor :code_lifespan

  included do
    include OAuth2::Provider::Models::TokenExpiry, OAuth2::Provider::Models::RandomToken
    self.default_token_lifespan = 1.minute

    delegate :client, :resource_owner, :to => :authorization
    validates_presence_of :authorization, :code, :expires_at, :redirect_uri
  end

  def initialize(*args)
    self.default_token_lifespan = self.code_lifespan if self.code_lifespan
    super
    self.code ||= self.class.unique_random_token(:code)
  end

  module ClassMethods
    def claim(code, redirect_uri)
      if authorization_code = find_by_code_and_redirect_uri(code, redirect_uri)
        if authorization_code.fresh?
          authorization_code.destroy
          authorization_code.authorization.access_tokens.create!
        end
      end
    end
  end
end