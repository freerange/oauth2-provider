module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env['oauth2'] = OAuth2::Provider::Rack::Mediator.new

      response = catch :oauth2 do
        handler(env).process
      end

      (env['oauth2'] && env['oauth2'].response) || response
    end

    def handler(env)
      request = Request.new(env)
      handler_class = request.access_token_path? ? AccessTokenHandler : AuthenticationHandler
      handler_class.new(@app, env)
    end
  end
end