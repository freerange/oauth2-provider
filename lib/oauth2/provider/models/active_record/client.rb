class OAuth2::Provider::Models::ActiveRecord::Client < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Shared::Client

      has_many :access_grants
      has_many :authorization_codes, :through => :access_grants
      has_many :access_tokens, :through => :access_grants
    end
  end

  include Behaviour
end