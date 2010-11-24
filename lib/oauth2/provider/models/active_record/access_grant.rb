class OAuth2::Provider::Models::ActiveRecord::AccessGrant < ActiveRecord::Base
  include OAuth2::Provider::Models::Shared::AccessGrant

  belongs_to :client
  belongs_to :account

  has_many :access_tokens
  has_many :authorization_codes
end