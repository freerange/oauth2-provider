class OAuth2::Provider::Models::ActiveRecord::AuthorizationCode < ActiveRecord::Base
  include OAuth2::Provider::TokenExpiry

  belongs_to :access_grant, :class_name => "OAuth2::Provider::Models::ActiveRecord::AccessGrant"
  validates_presence_of :access_grant, :code, :expires_at, :redirect_uri

  def self.claim(code, redirect_uri)
    if authorization_code = find_by_code_and_redirect_uri(code, redirect_uri)
      unless authorization_code.expired?
        authorization_code.destroy
        OAuth2::Provider::Models::ActiveRecord::AccessToken.create!(
          :access_grant => authorization_code.access_grant
        )
      end
    end
  end

  def initialize(attributes = {})
    super
    self.code ||= OAuth2::Provider::Random.base62(32)
    self.expires_at ||= 10.minutes.from_now
  end
end