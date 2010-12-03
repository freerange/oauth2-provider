class OAuth2::Provider::Rack::Mediator
  attr_reader :response
  attr_accessor :access_grant

  delegate :has_scope?, :to => :access_grant

  def authenticated?
    access_grant.present?
  end

  def authentication_required!
    challenge = "OAuth realm='Application'"
    @response = [401, {'Content-Type' => 'text/plain', 'Content-Length' => '0', 'WWW-Authenticate' => challenge}, []]
  end

  def insufficient_scope!
    @response = [403, {'Content-Type' => 'application/json'}, [%{{"error": "insufficient_scope"}}]]
  end
end