class OAuth2::Provider::AuthenticationMiddleware
  def initialize(app, config = nil)
    @app = app
  end

  def call(env)
    env['oauth2'] = OAuth2::Provider::Core.new
    @app.call(env)
  end
end