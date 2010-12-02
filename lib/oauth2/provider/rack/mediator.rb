class OAuth2::Provider::Rack::Mediator
  attr_accessor :access_grant

  delegate :has_scope?, :to => :access_grant

  def authenticated?
    access_grant.present?
  end

  def authentication_required!
    @authentication_required = true
  end

  def authentication_required?
    @authentication_required
  end

  def insufficient_scope?
    @insufficient_scope
  end

  def insufficient_scope!
    @insufficient_scope = true
  end
end