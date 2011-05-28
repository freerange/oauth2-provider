module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = env['oauth2'] = ResourceRequest.new(env)

      env['warden'] && env['warden'].custom_failure!

      response = catch :oauth2 do
        if request.path == "/oauth/access_token"
          AccessTokenHandler.new(@app, env).process
        else
          @app.call(env)
        end
      end
    rescue InvalidRequest => e
      [400, {}, e.message]
    end
  end
end