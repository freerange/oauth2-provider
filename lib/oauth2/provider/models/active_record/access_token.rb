class OAuth2::Provider::Models::ActiveRecord::AccessToken < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Shared::AccessToken

      belongs_to :access_grant, :class_name => "OAuth2::Provider::Models::ActiveRecord::AccessGrant"
    end
  end

  include Behaviour
end