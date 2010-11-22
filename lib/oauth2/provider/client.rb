class OAuth2::Provider::Client < ActiveRecord::Base
  validates_presence_of :oauth_identifier, :oauth_secret
  validates_uniqueness_of :oauth_identifier

  has_many :authorization_codes
  has_many :access_tokens

  def self.from_param(identifier)
    self.find_by_oauth_identifier(identifier)
  end

  def initialize(*args, &block)
    super
    self.oauth_identifier ||= OAuth2::Provider::Random.base62(16)
    self.oauth_secret ||= OAuth2::Provider::Random.base62(32)
  end

  def to_param
    new_record? ? nil : oauth_identifier
  end

  def allow_grant_type?(grant_type)
    true
  end
end