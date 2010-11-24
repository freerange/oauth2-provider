class OAuth2::Provider::Models::ActiveRecord::Client < ActiveRecord::Base
  include OAuth2::Provider::Models::Shared::Client

  has_many :access_grants
  has_many :authorization_codes, :through => :access_grants
  has_many :access_tokens, :through => :access_grants
end