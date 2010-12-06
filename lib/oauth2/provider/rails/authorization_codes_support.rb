require 'addressable/uri'

module OAuth2::Provider::Rails::AuthorizationCodesSupport
  protected

  def oauth2
    request.env['oauth2']
  end

  def block_invalid_authorization_code_requests
    unless params[:redirect_uri]
      render :text => 'No redirect_uri provided', :status => :bad_request and return
    end

    unless params[:client_id]
      oauth2.invalid_authorization_code_request!(params[:redirect_uri])
    end

    unless @oauth2_client = OAuth2::Provider.client_class.from_param(params[:client_id])
      oauth2.invalid_authorization_code_client!(params[:redirect_uri])
    end
  end

  def build_authorization_code(resource_owner = nil)
    @oauth2_client.authorization_codes.build(
      :access_grant => @oauth2_client.access_grants.build(
        :resource_owner => resource_owner,
        :client => @oauth2_client
      )
    )
  end

  def grant_authorization_code(resource_owner = nil)
    oauth2.grant_authorization_code!(params[:redirect_uri], @oauth2_client, resource_owner)
  end

  def deny_authorization_code
    oauth2.deny_authorization_code!(params[:redirect_uri])
  end

  def append_to_uri(uri, parameters = {})
    u = Addressable::URI.parse(uri)
    u.query_values = (u.query_values || {}).merge(parameters)
    u.to_s
  end

  def redirect_with_error(name)
    redirect_to append_to_uri(params[:redirect_uri], :error => name)
  end
end