require 'addressable/uri'

module OAuth2::Provider::Models::Client
  extend ActiveSupport::Concern

  included do
    include OAuth2::Provider::Models::RandomToken
    validates_presence_of :oauth_identifier, :oauth_secret, :name
    validates_uniqueness_of :oauth_identifier
  end

  def initialize(*args, &block)
    super
    self.oauth_identifier ||= self.class.unique_random_token(:oauth_identifier)
    self.oauth_secret ||= self.class.unique_random_token(:oauth_secret)
  end

  def to_param
    new_record? ? nil : oauth_identifier
  end

  def allow_grant_type?(grant_type)
    confidential? || grant_type != "client_credentials"
  end

  def allow_redirection?(uri)
    uri_host = Addressable::URI.parse(uri).host
    unless oauth_redirect_uri.nil? or oauth_redirect_uri.empty?
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
