class OAuth2::Provider::Models::ActiveRecord::AccessGrant < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Shared::AccessGrant

      belongs_to :client, :class_name => OAuth2::Provider.client_class_name, :foreign_key => 'client_id'
      belongs_to :account

      has_many :access_tokens
      has_many :authorization_codes
    end
  end

  include Behaviour
end