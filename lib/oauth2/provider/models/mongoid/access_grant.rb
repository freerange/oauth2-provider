class OAuth2::Provider::Models::Mongoid::AccessGrant
  include ::Mongoid::Document
  include OAuth2::Provider::Models::Shared::AccessGrant

  field :scope
  field :expires_at, :type => Time

  referenced_in :client, :class_name => "OAuth2::Provider::Models::Mongoid::Client"
  references_many :access_tokens, :class_name => "OAuth2::Provider::Models::Mongoid::AccessToken"
  references_many :authorization_codes, :class_name => "OAuth2::Provider::Models::Mongoid::AuthorizationCode"
end