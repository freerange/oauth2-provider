# The length of time that an access token is valid for.  Defaults to 1 month.
# Set a different time value here.  Note that the optional time that you grant
# a token for when you call grant_authorization_code must be greater than or
# equal to this time span.
#OAuth2::Provider::Models::AccessToken.token_lifespan = 1.month

# The length of time that an authorization code is valid for. Defaults to 1
# minute.
#OAuth2::Provider::Models::AuthorizationCode.code_lifespan = 1.minute

# When using a grant type of password, where a username and password are sent,
# a class must be provided that responds to a class method
# authenticate_with_username_and_password and returns an object that represents
# the user, or nil if the username and password are not authenticated
OAuth2::Provider.resource_owner_class_name = "Account"

# The API endpoint that this library will intercept for handling access token
# requests.  Any HTTP requests that end in this will be intercepted by the
# library, so if your site is running in a sub folder you do not need to set
# that here. The client must POST to this path with the following parameters:
#   grant_type - either "password", "authorization_code", or "refresh_token"
#   client_id - identifier for the client
#   client_secret - client's secret key
#   username, password - if grant type is "password"
#   code - if grant type is "access_token"
#   refresh_token - if grant type is "refresh_token"
#OAuth2::Provider.access_token_path = "/oauth/access_token"

# :activerecord or :mongoid
#OAuth2::Provider.backend = :activerecord

###############################################################################
# Table name overrides.  It is NOT recommended that you change these
###############################################################################
# Table that stores the oauth client info. Change the name here. It must
# contain the following columns:
#   oauth_identifier - string (required)
#   oauth_secret - string (required),
#   oauth_redirect_uri - string (not required)
#OAuth2::Provider::Models::ActiveRecord.client_table_name = 'oauth_clients'

# Table that stores the oauth access tokens. This is what the client to show
# that it has access to the system, the API call to /oauth/access_token grants
# access. Change the name here. It must contain the following fields:
#   authorization_id - foreign key pointing to the oauth_authorizations table (required)
#   access_token - string (required)
#   refresh_token - string (optional)
#   expires_at - datetime
#   created_at - datetime
#   updated_at - datetime
#OAuth2::Provider::Models::ActiveRecord.access_token_table_name = 'oauth_access_token'

# Table that stores the temporary authorization code that clients get to
# request a token with.  Change the name here.  It must contain the following
# fields:
#   authorization_id - foreign key pointing to the oauth_authorizations table (required)
#   code - string (required)
#   redirect_uri - string (optional)
#   expires_at - datetime
#   created_at - datetime
#   updated_at - datetime
#OAuth2::Provider::Models::ActiveRecord.authorization_code_table_name = 'oauth_access_token'

# Table that stores authorizations that resource owners have granted to the
# client. Change the name here. It must contain the following fields:
#   client_id - foreign key pointing to the oauth_clients table (required)
#   resource_owner_id - foreign key pointing to the row for the resource owner (required)
#   resource_owner_type - string, name of the model class representing the resource owner
#   scope - string
#   expires_at - datetime
#OAuth2::Provider::Models::ActiveRecord.authorization_table_name = 'oauth_access_token'

###############################################################################
# Overrides for the model class names.  It is NOT recommended that you modify
# these unless you need to write custom functionality. If you need custom
# functionality it's recommended that your class inherit from the default
# class rather than modifying the class in the library code.
###############################################################################
#OAuth2::Provider.client_class_name = "OAuth2::Provider::Models::ActiveRecord::Client"
#OAuth2::Provider.access_token_class_name = "OAuth2::Provider::Models::ActiveRecord::AccessToken"
#OAuth2::Provider.authorization_code_class_name = "OAuth2::Provider::Models::ActiveRecord::AuthorizationCode"
#OAuth2::Provider.authorization_class_name = "OAuth2::Provider::Models::ActiveRecord::Authorization"

