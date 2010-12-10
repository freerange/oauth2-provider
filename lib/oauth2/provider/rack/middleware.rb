module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env['oauth2'] = OAuth2::Provider::Rack::AuthenticationMediator.new(env)

      response = catch :oauth2 do
        handler(env).process
      end

      thrown_response(env) || response
    end

    def thrown_response(env)
      if env['oauth2.response']
        env['warden'] && env['warden'].custom_failure!
        env['oauth2.response']
      end
    end

    def handler(env)
      request = Request.new(env)
      handler_class = request.access_token_path? ? AccessTokenHandler : AuthenticationHandler
      handler_class.new(@app, env)
    end
  end
end