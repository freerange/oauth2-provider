class OAuth2::Provider::Models::ActiveRecord::AuthorizationCode < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Shared::AuthorizationCode

      belongs_to :access_grant, :class_name => OAuth2::Provider.access_grant_class_name, :foreign_key => 'access_grant_id'
    end
  end

  include Behaviour
end