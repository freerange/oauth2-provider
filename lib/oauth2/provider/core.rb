class OAuth2::Provider::Core
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
end