oauth2-provider
==

Simple OAuth2 provider code extracted from [hashblue.com](https://hashblue.com/)

Details
--

* Implements [draft 11](http://tools.ietf.org/html/draft-ietf-oauth-v2-11) of the oauth2 spec
* Handles the authorization_code, refresh_token, and password grant types
* Supports ActiveRecord and Mongoid

Getting up and running quickly
--

In your Gemfile:

    gem 'oauth2-provider', :git => 'git@github.com:freerange/oauth2-provider.git'

If you're using ActiveRecord, grab the schema out of `spec/schema.rb`, and run the migration.

To dish out authorization codes you will need to implement something like this.  This assumes that the client
redirects to a page where the user clicks to sign in, you have a model named Account that represents the users, the
ID of this account is saved in the session, and after the user clicks to sign in they are redirected "/oauth/authorize"

    class AuthorizationController < ApplicationController
      include OAuth2::Provider::Rack::AuthorizationCodesSupport

      before_filter :authenticate_user!
      before_filter :block_invalid_authorization_code_requests

      def new
        @client = oauth2_authorization_request.client
        # View should be a form that POSTs to "/oauth/authorize", asking the user for permission
      end

      def create
        if params[:yes].present?
          grant_authorization_code(current_user)
        else
          deny_authorization_code
        end
      end

      private
      def authenticate_user!
        deny_authorization_code unless current_account
      end

      def current_account
        session[:account_id] ? Account.find(session[:account_id]) : nil
      end
    end
        
And add a couple of routes:

    match "/oauth/authorize", :via => :get, :to => "authorization#new"
    match "/oauth/authorize", :via => :post, :to => "authorization#create"

oauth2-provider will handle requests to `/oauth/access_token` to handle conversion of authorization codes to access tokens.


Advanced Usage
--

See the client and Rails 3 example applications in the examples folder for how to use this library.

There are two ways to grant access tokens to clients.

### Granting tokens through authorization codes

The most common way to grant access tokens is by first granting an authorization code that the client uses to request
the access token.  The easiest way to do this is to use the functions in
[OAuth2::Provider::Rack::AuthorizationCodesSupport](https://github.com/freerange/oauth2-provider/blob/master/lib/oauth2/provider/rack/authorization_codes_support.rb).
Simply include this module in your controller that will handle the code requests.  See the code in
lib/oauth2/provider/rack/authorization_codes_support.rb for more details on what methods are available.  Determining how
and when to grant the authorization code is up to you.  The most common way is shown in the Rails 3 example.

oauth2-provider handles giving the access token. The client should simply make a request to "/oauth/access_token" (this
path can be changed by setting OAuth2::Provider.access_token_path) with the parameters grant_type (set to
authorization_code), code, client_id, client_secret, redirect_uri, and optionally scope.  If the code is valid the
response will be a JSON object that contains access_token, optionally refresh_token, and optionally scope.

### Granting tokens through a user name and password

If you want the client to send the user name and password to get an access token, you'll need to have a class that
can verify whether the user name and password are valid.  It must respond to a class method
authenticate_with_username_and_password and returns an object that represents the user, or nil if the username and
password are not authenticated.  Example:

    class Account < ActiveRecord::Base
      def self.authenticate_with_username_and_password(username, password)
        # Implement your own logic here for password checking, never store the
        # password in the database in plain text
        self.find_by_username_and_password(username, password)
      end
    end

Then you'll need to tell the oauth2-provider to use the Account class with

    OAuth2::Provider.resource_owner_class_name = "Account"

For Rails apps it's recommended that you put this line in a file in config/initializers.

With this set up, oauth2-provider will handle the rest.  The client should simply send a request to /oauth/access_token
with the parameters grant_type (set to "password"), client_id, client_secret, username, and password.  The client
will get JSON back with access_token, optionally refresh_token, and optionally expires_in.

### Verifying the access token

Once access is granted, and the client has a valid access token, you'll want some way of verifying the access token
and getting information on the resource owner on subsequent requests from the client.  There are two ways that the
client can send the token in subsequent requests:

* Add a parameter to the HTTP request named oauth_token
* Send an HTTP header named X-HTTP_AUTHORIZATION

In your controller, you can access the full OAuth2 authorization with:

    request.env['oauth2']

This will return an [OAuth2::Provider::Rack::ResourceRequest](https://github.com/freerange/oauth2-provider/blob/master/lib/oauth2/provider/rack/resource_request.rb).
You can call authenticated?, authorization, and resource_owner on this.  See
lib/oauth2-provider/rack/resource_request.rb for details on these methods.


OAuth2 Concepts
--

For a good overview of OAuth, visit http://hueniverse.com/oauth/.  The OAuth 1 concepts are very similar to OAuth 2.
Here is a brief description of the concepts that you should be concerned with when using this library:

* OAuth Client - A service that wants temporary access to resources under the control of the application using this
  library.  A client has an identifier and a secret key, and optionally a URL to redirect back to.
* Resource Owner - The entity that owns the resources here that the oauth client is requesting access to.  This is
  typically a user.  They must grant access to the client for the resource.
* OAuth authorization code - When a client requests access to a resource, and the resource owner logs in successfully
  here and grants access to the client, the oauth client will receive an authorization code.  This does not provide
  access.  This simply allows the client to request an access token.  The authorization code is only valid for 1 minute
  (default) so the client must immediately request the token.
* OAuth access token - this is a token that grants a client temporary access to the resource requested.  It is valid for
  1 month (default)
* OAuth refresh token - a second token granted when the client is authorized.  When the access token expires, the client
  can request a new access token using this refresh token, so the user does not have re-authorize. The amount of time
  that this is valid for is specified here when you grant an authorization code.
* OAuth redirect URI - this is the URL that the resource owner will be redirected back to after authorization is
  granted.
* OAuth scope - this is an optional string that represents the type of access that the client is requesting.
