class OAuth2::Provider::Models::Mongoid::AccessGrant
  include ::Mongoid::Document
  include OAuth2::Provider::Models::Shared::AccessGrant

  field :scope
  field :expires_at, :type => Time

  referenced_in :resource_owner, :class_name => OAuth2::Provider.resource_owner_class_name
  referenced_in :client, :class_name => OAuth2::Provider.client_class_name
  references_many :access_tokens, :class_name => OAuth2::Provider.access_token_class_name
  references_many :authorization_codes, :class_name => OAuth2::Provider.authorization_code_class_name
end