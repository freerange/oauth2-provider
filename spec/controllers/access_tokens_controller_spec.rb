require 'spec_helper'

class CustomClient < OAuth2::Provider::Client
end

class NotAllowedGrantTypeClient < OAuth2::Provider::Client
  def allow_grant_type?(grant_type)
    false
  end
end

describe OAuth2::Provider::AccessTokensController do
  before :each do
    @client = OAuth2::Provider::Client.create!
    @code = OAuth2::Provider::AuthorizationCode.create! :client => @client, :redirect_uri => "https://client.example.com/callback"
    @valid_params = {
      :grant_type => 'authorization_code',
      :client_id => @client.to_param,
      :client_secret => @client.oauth_secret,
      :code => @code.code,
      :redirect_uri => @code.redirect_uri
    }
  end

  describe "Any request without a client_id parameter" do
    before :each do
      post :create, @valid_params.except(:client_id)
    end

    responds_with_json_error 'invalid_request', :status => 400
  end

  describe "Any request without a client_secret parameter" do
    before :each do
      post :create, @valid_params.except(:client_secret)
    end

    responds_with_json_error 'invalid_request', :status => 400
  end

  describe "Any request without a grant_type parameter" do
    before :each do
      post :create, @valid_params.except(:grant_type)
    end

    responds_with_json_error 'invalid_request', :status => 400
  end

  describe "Any request with an unsupported grant_type" do
    before :each do
      post :create, @valid_params.merge('grant_type' => 'unsupported')
    end

    responds_with_json_error 'unsupported_grant_type', :status => 400
  end

  describe "Any request where the client_id is unknown" do
    before :each do
      post :create, @valid_params.merge(:client_id => 'unknown')
    end

    responds_with_json_error 'invalid_client', :status => 400
  end

  describe "Any request where the client_secret is wrong" do
    before :each do
      post :create, @valid_params.merge(:client_secret => 'wrongvalue')
    end

    responds_with_json_error 'invalid_client', :status => 400
  end

  describe "Any request where the client isn't allowed to use the requested grant type" do
    before :each do
      OAuth2::Provider.client_class_name = NotAllowedGrantTypeClient.name
      @client = NotAllowedGrantTypeClient.create!
      @code = OAuth2::Provider::AuthorizationCode.create! :client => @client, :redirect_uri => "https://client.example.com/callback"
      @valid_params = {
        :grant_type => 'authorization_code',
        :client_id => @client.to_param,
        :client_secret => @client.oauth_secret,
        :code => @code.code,
        :redirect_uri => @code.redirect_uri
      }
      post :create, @valid_params
    end

    responds_with_json_error 'unauthorized_client', :status => 400

    after :each do
      OAuth2::Provider.client_class_name = OAuth2::Provider::Client.name
    end
  end

  describe "A request using the authorization_code grant type" do
    describe "with valid client, code and redirect_uri" do
      before :each do
        post :create, @valid_params
      end

      it "responds with claimed access token, refresh token and expiry time in JSON" do
        token = OAuth2::Provider::AccessToken.find_by_access_token(json_from_response["access_token"])
        token.should_not be_nil
        json_from_response["expires_in"].should == token.expires_in
        json_from_response["refresh_token"].should == token.refresh_token
      end

      it "sets cache-control header to no-store, as response is sensitive" do
        response.headers["Cache-Control"].should =~ /no-store/
      end

      it "destroys the claimed code, so it can't be used a second time" do
        OAuth2::Provider::AuthorizationCode.find_by_id(@code.id).should be_nil
      end

      it "doesn't include a state in the JSON response" do
        json_from_response.keys.include?("state").should be_false
      end
    end

    describe "with valid client, code and redirect_uri and an additional state parameter" do
      before :each do
        post :create, @valid_params.merge(:state => 'some-state-goes-here')
      end

      it "includes the state in the JSON response" do
        json_from_response["state"].should == 'some-state-goes-here'
      end
    end

    describe "with an unknown code" do
      before :each do
        post :create, @valid_params.merge(:code => 'unknown')
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "with an incorrect redirect uri" do
      before :each do
        post :create, @valid_params.merge(:redirect_uri => 'https://wrong.example.com')
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "without a code parameter" do
      before :each do
        post :create, @valid_params.except(:code)
      end

      responds_with_json_error 'invalid_request', :status => 400
    end

    describe "without a redirect_uri parameter" do
      before :each do
        post :create, @valid_params.except(:redirect_uri)
      end

      responds_with_json_error 'invalid_request', :status => 400
    end
  end

  describe "A request using the password grant type" do
    before :each do
      @account = Account.create!(:username => 'name', :password => 'password')
      @valid_params = {
        :grant_type => 'password',
        :client_id => @client.to_param,
        :client_secret => @client.oauth_secret,
        :username => @account.username,
        :password => @account.password
      }
    end

    describe "with valid username and password" do
      before :each do
        post :create, @valid_params
      end

      it "responds with access token, refresh token and expiry time in JSON" do
        token = OAuth2::Provider::AccessToken.find_by_access_token(json_from_response["access_token"])
        token.should_not be_nil
        json_from_response["expires_in"].should == token.expires_in
        json_from_response["refresh_token"].should == token.refresh_token
      end

      it "sets cache-control header to no-store, as response is sensitive" do
        response.headers["Cache-Control"].should =~ /no-store/
      end

      it "doesn't include a state in the JSON response" do
        json_from_response.keys.include?("state").should be_false
      end
    end

    describe "with valid username and password and an additional state parameter" do
      before :each do
        post :create, @valid_params.merge(:state => 'some-state-goes-here')
      end

      it "includes the state in the JSON response" do
        json_from_response["state"].should == 'some-state-goes-here'
      end
    end

    describe "with an incorrect username" do
      before :each do
        post :create, @valid_params.merge(:username => 'wrong')
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "with an incorrect password" do
      before :each do
        post :create, @valid_params.merge(:password => 'wrong')
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "without a username parameter" do
      before :each do
        post :create, @valid_params.except(:username)
      end

      responds_with_json_error 'invalid_request', :status => 400
    end

    describe "without a password parameter" do
      before :each do
        post :create, @valid_params.except(:password)
      end

      responds_with_json_error 'invalid_request', :status => 400
    end
  end

  describe "A request using the refresh token grant type" do
    before :each do
      @token = OAuth2::Provider::AccessToken.create! :client => @client, :expires_at => 1.week.ago
      @valid_params = {
        :grant_type => 'refresh_token',
        :refresh_token => @token.refresh_token,
        :client_id => @client.to_param,
        :client_secret => @client.oauth_secret
      }
    end

    describe "with a valid refresh token" do
      before :each do
        post :create, @valid_params
      end

      it "responds with refreshed access token, refresh token and expiry time in JSON" do
        token = OAuth2::Provider::AccessToken.find_by_access_token(json_from_response["access_token"])
        token.should_not be_nil
        token.should_not == @token
        json_from_response["expires_in"].should == token.expires_in
        json_from_response["refresh_token"].should == token.refresh_token
      end
    end

    describe "when the token belongs to a different client" do
      before :each do
        @other_client = OAuth2::Provider::Client.create!
        post :create, @valid_params.merge(:client_id => @other_client.oauth_identifier, :client_secret => @other_client.oauth_secret)
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "when the token is incorrect" do
      before :each do
        post :create, @valid_params.merge(:refresh_token => 'incorrect')
      end

      responds_with_json_error 'invalid_grant', :status => 400
    end

    describe "without a refresh_token parameter" do
      before :each do
        post :create, @valid_params.except(:refresh_token)
      end

      responds_with_json_error 'invalid_request', :status => 400
    end
  end

  describe "When using a custom client class" do
    before :each do
      OAuth2::Provider.client_class_name = "CustomClient"
      @client = CustomClient.create!
      @client_params = {
        :client_id => @client.to_param,
        :client_secret => @client.oauth_secret,
      }
    end

    describe "requests using authorization code grant type" do
      before :each do
        @code = OAuth2::Provider::AuthorizationCode.create! :client => @client, :redirect_uri => "https://client.example.com/callback"
        @valid_params = @client_params.merge(
          :grant_type => 'authorization_code',
          :code => @code.code,
          :redirect_uri => @code.redirect_uri
        )
        post :create, @valid_params
      end

      it "are still successful" do
        response.should be_successful
      end
    end

    describe "requests using password grant type" do
       before :each do
         @account = Account.create!(:username => 'name', :password => 'password')
         @valid_params = @client_params.merge(
           :grant_type => 'password',
           :username => @account.username,
           :password => @account.password
         )
         post :create, @valid_params
       end

       it "are still successful" do
         response.should be_successful
       end
     end
  end

  after :each do
    OAuth2::Provider.client_class_name = OAuth2::Provider::Client.name
  end
end
