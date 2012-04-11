require 'addressable/uri'

module OAuth2::Provider::Rack::Responses
  def self.unauthorized(error = nil)
    challenge = "OAuth2"
    challenge << %{ error="#{error}"} if error
    [401, {'Content-Type' => 'text/plain', 'Content-Length' => '0', 'WWW-Authenticate' => challenge}, []]
  end

  def self.only_supported(supported)
    [405, {'Allow' => supported}, ["Only #{supported} requests allowed"]]
  end

  def self.json_error(error, options = {})
    description = %{, "error_description": "#{options[:description]}"} if options[:description]
    [options[:status] || 400, {'Content-Type' => 'application/json'}, [%{{"error": "#{error}"#{description}}}]]
  end

  def self.redirect_with_error(error, uri)
    [302, {'Location' => append_to_uri(uri, :error => error)}, []]
  end

  def self.redirect_with_code(code, uri)
    [302, {'Location' => append_to_uri(uri, :code => code)}, []]
  end

  def self.redirect_with_hash_params(uri, params)
    [302, {'Location' => append_to_uri(uri) + "##{params.to_query}"}, []]
  end

  def insufficient_scope!
    throw_response OAuth2::Provider::Rack::Responses.json_error('insufficient_scope', :status => 403)
  end

  def invalid_request!(description)
    throw_response OAuth2::Provider::Rack::Responses.json_error('invalid_request', :description => description, :status => 401)
  end

  def authentication_required!(reason = nil)
    env['warden'] && env['warden'].custom_failure!
    throw_response OAuth2::Provider::Rack::Responses.unauthorized(reason)
  end

  private

  def self.append_to_uri(uri, parameters = {})
    u = Addressable::URI.parse(uri)
    u.query_values = (u.query_values || {}).merge(parameters)
    u.to_s
  end

  def throw_response(response)
    throw :oauth2, response
  end
end