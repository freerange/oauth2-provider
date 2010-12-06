require 'addressable/uri'

module OAuth2::Provider::Rails::AuthorizationCodesSupport
  protected

  def block_invalid_authorization_code_requests
    unless params[:redirect_uri]
      render :text => 'No redirect_uri provided', :status => :bad_request and return
    end

    unless params[:client_id]
      redirect_with_error 'invalid_request' and return
    end

    unless @oauth2_client = OAuth2::Provider.client_class.from_param(params[:client_id])
      redirect_with_error 'invalid_client' and return
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
    grant = @oauth2_client.access_grants.create!(
      :resource_owner => resource_owner,
      :client => @oauth2_client
    )
    code = grant.authorization_codes.create! :redirect_uri => params[:redirect_uri]
    redirect_to append_to_uri(params[:redirect_uri], :code => code.code)
  end

  def deny_authorization_code
    redirect_with_error 'access_denied'
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