class OAuth2::Provider::Models::ActiveRecord::Client < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Shared::Client

      has_many :access_grants, :class_name => OAuth2::Provider.access_grant_class_name, :foreign_key => 'client_id'
      has_many :authorization_codes, :through => :access_grants, :class_name => OAuth2::Provider.authorization_code_class_name, :foreign_key => 'client_id'
      has_many :access_tokens, :through => :access_grants, :class_name => OAuth2::Provider.access_token_class_name, :foreign_key => 'client_id'
    end
  end

  include Behaviour
end