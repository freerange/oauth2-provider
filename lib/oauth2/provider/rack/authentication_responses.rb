module OAuth2::Provider::Rack::AuthenticationResponses
  extend ActiveSupport::Concern

  included do |base|
    class_attribute :authentication_realm
    self.authentication_realm = 'OAuth2'
  end

  def invalid_request!(description = nil)
    throw_response!(400, {"WWW-Authenticate" => authenticate_header('invalid_request', description)})
  end

  def invalid_token!(description = nil)
    throw_response!(401, {"WWW-Authenticate" => authenticate_header('invalid_token', description)})
  end

  def throw_response!(status, headers, body = [])
    throw :oauth2, [status, headers, body]
  end

  private

  def authenticate_header(error, description = nil)
    %{Bearer realm="#{authentication_realm}" error="#{error}"}.tap do |result|
      result << %{ error_description="#{description}"} if description
    end
  end
end
