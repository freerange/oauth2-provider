module OAuth2::Provider::Models::AuthorizationCode
  extend ActiveSupport::Concern

  included do
    delegate :client, :resource_owner, :to => :access_grant

    include OAuth2::Provider::Models::TokenExpiry
    validates_presence_of :access_grant, :code, :expires_at, :redirect_uri
  end

  def initialize(attributes = {})
    super
    self.code ||= OAuth2::Provider::Random.base62(32)
    self.expires_at ||= 10.minutes.from_now
  end

  module ClassMethods
    def claim(code, redirect_uri)
      if authorization_code = find_by_code_and_redirect_uri(code, redirect_uri)
        unless authorization_code.expired?
          authorization_code.destroy
          authorization_code.access_grant.access_tokens.create!
        end
      end
    end
  end
end