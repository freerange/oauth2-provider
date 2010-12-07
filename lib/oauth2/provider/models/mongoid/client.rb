class OAuth2::Provider::Models::Mongoid::Client
  include ::Mongoid::Document
  include OAuth2::Provider::Models::Client

  field :oauth_secret
  field :oauth_identifier

  references_many :authorizations, :class_name => "OAuth2::Provider::Models::Mongoid::Authorization"
  references_many :access_tokens, :class_name => "OAuth2::Provider::Models::Mongoid::AccessToken"
  references_many :authorization_codes, :class_name => "OAuth2::Provider::Models::Mongoid::AuthorizationCode"

  def self.find_by_oauth_identifier(identifier)
    where(:oauth_identifier => identifier).first
  end

  def self.find_by_oauth_identifier_and_oauth_secret(identifier, secret)
    where(:oauth_identifier => identifier, :oauth_secret => secret).first
  end
end