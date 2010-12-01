class OAuth2::Provider::Rack::Middleware
  def initialize(app, handler_class)
    @app = app
    @handler_class = handler_class
  end

  def call(env)
    @handler_class.new(@app, env).response
  end
end