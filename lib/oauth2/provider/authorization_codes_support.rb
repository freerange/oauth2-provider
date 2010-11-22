require 'addressable/uri'

module OAuth2::Provider::AuthorizationCodesSupport
  protected

  def block_invalid_authorization_code_requests
    unless params[:client_id] && params[:redirect_uri]
      render :text => 'Client Not Found', :status => :not_found and return
    end

    unless @client = OAuth2::Provider::Client.from_param(params[:client_id])
      render :text => 'Client Not Found', :status => :not_found and return
    end
  end

  def grant_authorization_code(account = nil)
    authorization_code = @client.authorization_codes.create!(
      :account => account,
      :redirect_uri => params[:redirect_uri]
    )
    redirect_to append_to_uri(params[:redirect_uri], :code => authorization_code.code)
  end

  def deny_authorization_code
    redirect_to append_to_uri(params[:redirect_uri], :error => 'access_denied')
  end

  def append_to_uri(uri, parameters = {})
    u = Addressable::URI.parse(uri)
    u.query_values = (u.query_values || {}).merge(parameters)
    u.to_s
  end
end