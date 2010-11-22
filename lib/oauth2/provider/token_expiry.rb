module OAuth2::Provider::TokenExpiry
  def expired?
    self.expires_at < Time.zone.now
  end

  def expires_in
    if expired?
      0
    else
      self.expires_at.to_i - Time.zone.now.to_i
    end
  end
end