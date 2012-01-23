module OAuth2::Provider::Rack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = env['oauth2'] = ResourceRequest.new(env)

      response = catch :oauth2 do
        # The token path must be at the end of the URL, allowing sites to run in folders
        if request.path.end_with?(OAuth2::Provider.access_token_path)
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