class Account < ActiveRecord::Base
  def self.authenticate_with_username_and_password(username, password)
    # N.B. Don't use this for authentication in a real app
    find_by_login_and_password(username, password)
  end
end