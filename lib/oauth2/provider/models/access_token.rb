module OAuth2::Provider::Models::AccessToken
  extend ActiveSupport::Concern

  included do
    include OAuth2::Provider::Models::TokenExpiry, OAuth2::Provider::Models::RandomToken
    self.default_token_lifespan = 1.month

    validates_presence_of :authorization, :access_token, :expires_at
    validate :expires_at_isnt_greater_than_authorization

    delegate :scope, :has_scope?, :client, :resource_owner, :to => :authorization
  end

  def initialize(attributes = {}, options = {}, &block)
    super attributes.reverse_merge(:access_token => self.class.unique_random_token(:access_token), :refresh_token => self.class.unique_random_token(:refresh_token)), options
  end

  def as_json(options = {})
    {"access_token" => access_token, "expires_in" => expires_in}.tap do |result|
      result["refresh_token"] = refresh_token if refresh_token.present?
    end
  end

  def refreshable?
    refresh_token.present? && authorization.fresh?
  end

  private

  def expires_at_isnt_greater_than_authorization
    if !authorization.nil? && authorization.expires_at
      unless expires_at.nil? || expires_at <= authorization.expires_at
        errors.add(:expires_at, :must_be_less_than_authorization)
      end
    end
  end

  module ClassMethods
    def refresh_with(refresh_token)
      if refresh_token && token = find_by_refresh_token(refresh_token)
        if token.refreshable?
          new(:authorization => token.authorization).tap do |result|
            if result.authorization.expires_at && result.authorization.expires_at < result.expires_at
              result.expires_at = result.authorization.expires_at
            end
            result.save!
          end
        end
      end
    end
  end
end
