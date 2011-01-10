module OAuth2::Provider::Rack
  class AuthenticationHandler
    attr_reader :app, :env, :request, :mediator

    delegate :insufficient_scope?, :authentication_required?, :to => :mediator

    def initialize(app, env)
      @app = app
      @env = env
      @request = OAuth2::Provider::Rack::Request.new(env)
      @mediator = @env['oauth2']
    end

    def process
      if request.has_token?
        block_bad_request || block_invalid_token || app.call(env)
      else
        app.call(env)
      end
    end

    def block_bad_request
      if request.token_from_param && request.token_from_header && (request.token_from_param != request.token_from_header)
        throw_response Responses.json_error('invalid_request')
      end
    end

    def block_invalid_token
      access_token = OAuth2::Provider.access_token_class.find_by_access_token(request.token)
      mediator.authorization = access_token.authorization if access_token
      throw_response Responses.unauthorized('invalid_token') if access_token.nil? || access_token.expired?
    end

    private

    def throw_response(response)
      @env['oauth2.response'] = response
      throw :oauth2
    end
  end
end