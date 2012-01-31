module OAuth2::Provider::Rack::AuthorizationCodesSupport
  protected

  # Returns an OAuth2::Provider::Rack::AuthorizationCodeRequest, if the request
  # is for a new authorization code.  This will perform a check and if the
  # request is not for a new code or the code request is not valid, an error
  # will occur
  def oauth2_authorization_request
    request.env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
  end

  alias :block_invalid_authorization_code_requests :oauth2_authorization_request

  # If a valid authorization exists for the client and scope from the
  # parameters, and the resource owner passed in, a new code will be granted
  # and the user will be redirected back to the redirect_uri with the code
  # as a parameter.
  def regrant_existing_authorizations(resource_owner=nil)
    oauth2_authorization_request.grant_existing! resource_owner
  end

  # Grants an authorization code for the client specified in the params on
  # behalf of the resource owner passed in.  You can optionally specify a time
  # when this authorization will expire.  Note that this time must be greater
  # greater than or equal to now + the access token lifespan (defaults 1 month,
  # can be overridden by setting
  # OAuth2::Provider::Models::AccessToken.token_lifespan).
  # This will redirect back to the redirect_uri with the new code as a
  # parameter
  def grant_authorization_code(resource_owner = nil, authorization_expires_at = nil)
    oauth2_authorization_request.grant! resource_owner, authorization_expires_at
  end

  # Explicitly deny the request for an authorization code. This will redirect
  # back to the redirect_uri with an error parameter instead of a code.
  def deny_authorization_code
    oauth2_authorization_request.deny!
  end

  # Explicitly declare that the provided scope is invalid. This will redirect
  # back to the redirect_uri with an error parameter instead of a code.
  def declare_oauth_scope_invalid
    oauth2_authorization_request.invalid_scope!
  end
end