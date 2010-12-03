module OAuth2::Provider::Rack::Responses
  def self.unauthorized(error = nil)
    challenge = "OAuth realm='Application'"
    challenge << ", error='#{error}'" if error
    [401, {'Content-Type' => 'text/plain', 'Content-Length' => '0', 'WWW-Authenticate' => challenge}, []]
  end

  def self.only_supported(supported)
    [405, {'Allow' => supported}, ["Only #{supported} requests allowed"]]
  end

  def self.json_error(error, options = {})
    [options[:status] || 400, {'Content-Type' => 'application/json'}, [%{{"error": "#{error}"}}]]
  end
end