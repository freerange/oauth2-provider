class OAuth2::Provider::Models::ActiveRecord::AccessGrant < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::AccessGrant

      belongs_to :client, :class_name => OAuth2::Provider.client_class_name, :foreign_key => 'client_id'
      belongs_to :resource_owner, :class_name => OAuth2::Provider.resource_owner_class_name

      has_many :access_tokens, :class_name => OAuth2::Provider.access_token_class_name, :foreign_key => 'access_grant_id'
      has_many :authorization_codes, :class_name => OAuth2::Provider.authorization_code_class_name, :foreign_key => 'access_grant_id'
    end
  end

  include Behaviour
end