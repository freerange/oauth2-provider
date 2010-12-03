module OAuth2::Provider::Models::Shared::TokenExpiry
  def expired?
    self.expires_at && self.expires_at < Time.now
  end

  def expires_in
    if expired?
      0
    else
      self.expires_at.to_i - Time.now.to_i
    end
  end
end