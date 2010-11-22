module OAuth2::Provider::TokenScope
  def has_scope?(s)
    scope && scope.split(" ").include?(s)
  end
end