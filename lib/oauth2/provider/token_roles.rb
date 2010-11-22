module OAuth2::Provider::TokenRoles
  def roles
    super ? super.split(" ") : []
  end
end