require 'addressable/uri'

module OAuth2::Provider::Rails::AuthorizationCodesSupport
  protected

  def oauth2_authorization_request
    request.env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.env, request.params)
  end

  def block_invalid_authorization_code_requests
    oauth2_authorization_request.validate!
  end

  def grant_authorization_code(resource_owner = nil)
    oauth2_authorization_request.grant! resource_owner
  end

  def deny_authorization_code
    oauth2_authorization_request.deny!
  end
end