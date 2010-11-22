class OAuth2::Provider::AuthorizationCode < ActiveRecord::Base
  include OAuth2::Provider::TokenExpiry

  belongs_to :client, :class_name => OAuth2::Provider.client_class_name
  belongs_to :account

  validates_presence_of :code, :expires_at, :redirect_uri

  def self.claim(code, redirect_uri)
    if authorization_code = find_by_code_and_redirect_uri(code, redirect_uri)
      unless authorization_code.expired?
        authorization_code.destroy
        OAuth2::Provider::AccessToken.create!(
          :scope => authorization_code.scope,
          :client => authorization_code.client,
          :account => authorization_code.account
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