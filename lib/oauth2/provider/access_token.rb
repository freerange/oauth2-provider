class OAuth2::Provider::AccessToken < ActiveRecord::Base
  include OAuth2::Provider::TokenExpiry
  include OAuth2::Provider::TokenRoles

  belongs_to :client, :class_name => OAuth2::Provider.client_class_name
  belongs_to :account

  validates_presence_of :client, :access_token, :expires_at

  def initialize(*args, &block)
    super
    self.access_token ||= OAuth2::Provider::Random.base62(32)
    self.expires_at ||= 1.month.from_now
  end

  def as_json(options = {})
    {"access_token" => access_token, "expires_in" => expires_in}
  end
end