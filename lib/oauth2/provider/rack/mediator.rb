class OAuth2::Provider::Rack::Mediator
  attr_accessor :access_token

  def authenticated?
    access_token.present?
  end

  def authentication_required!
    @authentication_required = true
  end

  def authentication_required?
    @authentication_required
  end

  def insufficient_scope!
    @insufficient_scope = true
  end

  def insufficient_scope?
    @insufficient_scope
  end

  def resource_owner
    access_token && access_token.access_grant.resource_owner
  end
end