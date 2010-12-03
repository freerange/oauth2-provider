module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Request.new(env)
      response = handler_class.new(@app, env).process
      (env['oauth2'] && env['oauth2'].response) || response
    end

    def handler_class
      @request.access_token_path? ? AccessTokenHandler : AuthenticationHandler
    end
  end
end