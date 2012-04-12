class OAuth2::Provider::Models::Mongoid::Authorization
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include ::Mongoid::Document
      include OAuth2::Provider::Models::Authorization

      field :scope
      field :expires_at, :type => Time
      field :resource_owner_id
      field :resource_owner_type

      belongs_to(:client,
        :class_name => OAuth2::Provider.client_class_name,
        :foreign_key => :oauth_client_id
      )

      has_many(:access_tokens,
        :class_name => OAuth2::Provider.access_token_class_name,
        :foreign_key => :oauth_authorization_id
      )

      has_many(:authorization_codes,
        :class_name => OAuth2::Provider.authorization_code_class_name,
        :foreign_key => :oauth_authorization_id
      )
    end
  end

  include Behaviour
end