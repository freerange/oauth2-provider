class OAuth2::Provider::Models::ActiveRecord::AccessToken < ActiveRecord::Base
  include OAuth2::Provider::TokenExpiry

  belongs_to :access_grant, :class_name => "OAuth2::Provider::Models::ActiveRecord::AccessGrant"
  validates_presence_of :access_grant, :access_token, :expires_at
  validate :expires_at_isnt_greater_than_access_grant

  delegate :scope, :has_scope?, :to => :access_grant

  def initialize(*args, &block)
    super
    self.access_token ||= OAuth2::Provider::Random.base62(32)
    self.refresh_token ||= OAuth2::Provider::Random.base62(32)
    self.expires_at ||= 1.month.from_now
  end

  def as_json(options = {})
    {"access_token" => access_token, "expires_in" => expires_in}.tap do |result|
      result["refresh_token"] = refresh_token if refresh_token.present?
    end
  end

  def self.refresh_with(refresh_token)
    if token = find_by_refresh_token(refresh_token)
      if token.refreshable?
        new(:access_grant => token.access_grant).tap do |result|
          if result.access_grant.expires_at && result.access_grant.expires_at < result.expires_at
            result.expires_at = result.access_grant.expires_at
          end
          result.save!
        end
      end
    end
  end

  def refreshable?
    refresh_token.present?
  end

  private

  def expires_at_isnt_greater_than_access_grant
    if access_grant && access_grant.expires_at
      unless expires_at.nil? || expires_at <= access_grant.expires_at
        errors.add(:expires_at, :must_be_less_than_access_grant)
      end
    end
  end
end