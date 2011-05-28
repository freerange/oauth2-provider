require 'addressable/uri'

module OAuth2::Provider::Models::Client
  extend ActiveSupport::Concern

  included do
    validates_presence_of :oauth_identifier, :oauth_secret, :name
    validates_uniqueness_of :oauth_identifier
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

  def valid_redirection?(uri)
    uri_host = Addressable::URI.parse(uri).host
    if oauth_redirect_uri
      Addressable::URI.parse(oauth_redirect_uri).host == uri_host
    else
      !uri_host.nil? && true
    end
  rescue Addressable::URI::InvalidURIError
    false
  end

  module ClassMethods
    def from_param(identifier)
      self.find_by_oauth_identifier(identifier)
    end
  end
end