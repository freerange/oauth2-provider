module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env['oauth2'] = ResourceRequest.new(env)

      response = catch :oauth2 do
        request = Request.new(env)
        if request.access_token_path?
          AccessTokenHandler.new(@app, env).process
        else
          @app.call(env)
        end
      end

      thrown_response(env) || response
    end

    def thrown_response(env)
      if env['oauth2.response']
        env['warden'] && env['warden'].custom_failure!
        env['oauth2.response']
      end
    end
  end
end