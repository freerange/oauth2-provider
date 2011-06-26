module OAuth2::Provider::Models::AuthorizationCode
  extend ActiveSupport::Concern

  included do
    include OAuth2::Provider::Models::TokenExpiry, OAuth2::Provider::Models::RandomToken
    self.default_token_lifespan = 1.minute

    delegate :client, :resource_owner, :to => :authorization
    validates_presence_of :authorization, :code, :expires_at, :redirect_uri
  end

  def initialize(*args)
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