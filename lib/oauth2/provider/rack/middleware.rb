module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = env['oauth2'] = ResourceRequest.new(env)

      response = catch :oauth2 do
        if request.path =~ /\/oauth\/access_token/
          handle_access_token_request(env)
        else
          @app.call(env)
        end
      end
    rescue InvalidRequest => e
      [400, {}, e.message]
    end

    def handle_access_token_request(env)
      AccessTokenHandler.new(@app, env).process
    end
  end
end