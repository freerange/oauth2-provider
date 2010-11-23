class OAuth2::Provider::AccessGrant < ActiveRecord::Base
  include OAuth2::Provider::TokenExpiry

  validates_presence_of :client

  belongs_to :client
  belongs_to :account

  has_many :access_tokens
  has_many :authorization_codes

  def has_scope?(s)
    scope && scope.split(" ").include?(s)
  end

  def revoke
    authorization_codes.destroy_all
    access_tokens.destroy_all
    destroy
  end
end