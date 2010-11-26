module OAuth2::Provider::Models::Shared::AccessGrant
  extend ActiveSupport::Concern

  included do
    include OAuth2::Provider::Models::Shared::TokenExpiry
    validates_presence_of :client
  end

  def has_scope?(s)
    scope && scope.split(" ").include?(s)
  end

  def revoke
    authorization_codes.destroy_all
    access_tokens.destroy_all
    destroy
  end
end