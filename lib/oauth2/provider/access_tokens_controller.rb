class OAuth2::Provider::AccessTokensController < ApplicationController
  before_filter :block_unsupported_grant_types
  before_filter :block_invalid_clients

  def create
    send "handle_#{params[:grant_type]}_grant_type"
  end

  private

  def handle_authorization_code_grant_type
    with_required_params :code, :redirect_uri do |code, redirect_uri|
      if token = oauth_client.authorization_codes.claim(code, redirect_uri)
        render_token token
      else
        render_json_error 'invalid_grant'
      end
    end
  end

  def handle_password_grant_type
    with_required_params :username, :password do |username, password|
      if account = OAuth2::Provider.end_user_class.authenticate_with_username_and_password(username, password)
        render_token OAuth2::Provider::AccessToken.create! :account => account, :client => oauth_client
      else
        render_json_error 'invalid_grant'
      end
    end
  end

  def handle_refresh_token_grant_type
    with_required_params :refresh_token do |refresh_token|
      if token = @oauth_client.access_tokens.refresh_with(refresh_token)
        render_token token
      else
        render_json_error 'invalid_grant'
      end
    end
  end

  def with_required_params(*names, &block)
    values = params.values_at(*names)
    if values.include?(nil)
      render_json_error 'invalid_request'
    else
      yield *values
    end
  end

  def block_unsupported_grant_types
    with_required_params :grant_type do |grant_type|
      unless respond_to?("handle_#{grant_type}_grant_type", true)
        render_json_error 'unsupported_grant_type'
      end
    end
  end

  def block_invalid_clients
    with_required_params :client_id, :client_secret do |client_id, client_secret|
      @oauth_client = OAuth2::Provider.client_class.find_by_oauth_identifier_and_oauth_secret(client_id, client_secret)
      if @oauth_client.nil?
        render_json_error 'invalid_client'
      elsif !@oauth_client.allow_grant_type?(params[:grant_type])
        render_json_error 'unauthorized_client'
      end
    end
  end

  def oauth_client
    @oauth_client
  end

  def render_token(token)
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    json = token.as_json.tap do |json|
      json[:state] = params[:state] if params[:state]
    end
    render :json => json
  end

  def render_json_error(error, options = {})
    render :json => {'error' => error}, :status => (400 || options[:status])
  end
end