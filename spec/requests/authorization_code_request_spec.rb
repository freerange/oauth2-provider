require 'spec_helper'

describe OAuth2::Provider::Rack::AuthorizationCodeRequest do
  describe "#initialize" do
    before :each do
      @client = OAuth2::Provider.client_class.create! :name => 'client'
      @valid_params = {
        'client_id' => @client.oauth_identifier,
        'redirect_uri' => "https://redirect.example.com/callback",
        'response_type' => 'code'
      }
    end

    describe "with a valid client_id and redirect_uri" do
      it "doesn't raise any exception" do
        lambda {
          OAuth2::Provider::Rack::AuthorizationCodeRequest.new(@valid_params)
        }.should_not raise_error
      end
    end

    describe "without a client_id" do
      it "raises OAuth2::Provider::Rack::InvalidRequest" do
        lambda {
          OAuth2::Provider::Rack::AuthorizationCodeRequest.new(@valid_params.except('client_id'))
        }.should raise_error(OAuth2::Provider::Rack::InvalidRequest)
      end
    end

    describe "with an unknown client" do
      it "raises OAuth2::Provider::Rack::InvalidRequest" do
        lambda {
          OAuth2::Provider::Rack::AuthorizationCodeRequest.new(@valid_params.merge(
            'client_id' => 'unknown'
          ))
        }.should raise_error(OAuth2::Provider::Rack::InvalidRequest)
      end
    end

    describe "without a redirect_uri" do
      it "raises OAuth2::Provider::Rack::InvalidRequest" do
        lambda {
          OAuth2::Provider::Rack::AuthorizationCodeRequest.new(@valid_params.except('redirect_uri'))
        }.should raise_error(OAuth2::Provider::Rack::InvalidRequest)
      end
    end

    describe "with a redirect_uri the client regards as invalid" do
      before :each do
        OAuth2::Provider.client_class.stubs(:from_param).returns(@client)
        @client.expects(:allow_redirection?).with(@valid_params['redirect_uri']).returns(false)
      end

      it "raises OAuth2::Provider::Rack::InvalidRequest" do
        lambda {
          OAuth2::Provider::Rack::AuthorizationCodeRequest.new(@valid_params)
        }.should raise_error(OAuth2::Provider::Rack::InvalidRequest)
      end
    end
  end

  describe "#grant_existing!(resource_owner)" do
    before :each do
      @client = OAuth2::Provider.client_class.create! :name => 'client'
      @owner = create_resource_owner
      @scope = 'a-scope'
      @request = OAuth2::Provider::Rack::AuthorizationCodeRequest.new(
        'client_id' => @client.oauth_identifier,
        'redirect_uri' => "https://redirect.example.com/callback",
        'response_type' => 'code',
        'scope' => @scope
      )
    end

    describe "when matching authorization exists" do
      before :each do
        @authorization = create_authorization(:client => @client, :resource_owner => @owner, :scope => @scope)
      end

      it "throws an oauth2 response" do
        lambda {
          @request.grant_existing!(@owner)
        }.should throw_symbol(:oauth2)
      end

      it "creates an authorization code for the matching authorization" do
        catch :oauth2 do
          @request.grant_existing!(@owner)
        end
        code = @authorization.reload.authorization_codes.first
        code.should_not be_nil
        code.redirect_uri.should eql("https://redirect.example.com/callback")
      end

      it "includes authorization code in the response" do
        response = catch :oauth2 do
          @request.grant_existing!(@owner)
        end
        code = @authorization.reload.authorization_codes.first
        uri = response[1]["Location"]
        Addressable::URI.parse(uri).query_values['code'].should == code.code
      end
    end

    describe "when no matching authorization exists" do
      it "returns normally" do
        lambda {
          @request.grant_existing!(@owner)
        }.should_not throw_symbol(:oauth2)
      end
    end
  end
end

describe OAuth2::Provider::Rack::AuthorizationCodeRequest do
  before :each do
    ExampleResourceOwner.destroy_all
    @client = OAuth2::Provider.client_class.create! :name => 'client'
    @valid_params = {
      :client_id => @client.oauth_identifier,
      :redirect_uri => "https://redirect.example.com/callback",
      :response_type => 'code'
    }
    @owner = create_resource_owner
  end

  describe "Validating requests" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      successful_response
    end

    describe "Any request with a client_id and redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params
      end

      it "is successful" do
        response.status.should == 200
      end
    end

    describe "Any request without a client_id" do
      before :each do
        get '/oauth/authorize', @valid_params.except(:client_id)
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "Any request without a redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params.except(:redirect_uri)
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "Any request with an invalid redirect_uri" do
      before :each do
        get '/oauth/authorize', @valid_params.merge(:redirect_uri => "http://")
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "Any request with an unknown client id" do
      before :each do
        get '/oauth/authorize', @valid_params.merge(:client_id => 'unknown')
      end

      it "returns 400" do
        response.status.should == 400
      end
    end

    describe "A request where the scope is declared invalid" do
      action do |env|
        request = Rack::Request.new(env)
        env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
        env['oauth2.authorization_request'].invalid_scope!
        successful_response
      end

      before :each do
        get '/oauth/authorize', @valid_params
      end

      redirects_back_with_error 'invalid_scope'
    end
  end

  describe "Intercepting invalid requests" do
    action do |env|
      request = Rack::Request.new(env)
      begin
        env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
        successful_response
      rescue OAuth2::Provider::Rack::InvalidRequest => e
        [418, {'Content-Type' => 'text/plain'}, e.to_s]
      end
    end

    before :each do
      get '/oauth/authorize', @valid_params.except(:client_id)
    end

    it "should return the specific response" do
      response.status.should == 418
    end
  end

  describe "When the client has a redirect_uri attribute" do
    before :each do
      @client = OAuth2::Provider.client_class.create! :name => 'client', :oauth_redirect_uri => "https://redirect.example.com/callback"
      @valid_params = {
        :client_id => @client.oauth_identifier,
        :redirect_uri => "https://redirect.example.com/callback",
        :response_type => 'code'
      }
    end

    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      successful_response
    end

    it "returns a 400 if the redirect_uri parameter doesn't match hostnames" do
      get '/oauth/authorize', @valid_params.merge(:redirect_uri => "https://evil.example.com/callback")
      response.status.should == 400
    end

    it "returns a 200 if the redirect_uri parameter matches hostname but the path is different" do
      get '/oauth/authorize', @valid_params.merge(:redirect_uri => "https://redirect.example.com/other_callback")
      response.status.should == 200
    end
  end

  describe "Granting a token" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes', :response_type => 'token')
    end

    it "redirects back to the redirect_uri with a valid authorization code for the client" do
      response.status.should == 302
      query_values = Addressable::URI.parse(response.location.gsub(/\??#/, '?')).query_values
      query_values.keys.should == ["access_token"]
      token = query_values["access_token"]
      token.should_not be_nil
      found = OAuth2::Provider.access_token_class.find_by_access_token(token)
      found.should_not be_nil
      found.authorization.client.should == @client
      found.authorization.resource_owner.should == @owner
      found.should_not be_expired
    end
  end

  describe "Granting a code" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes')
    end

    it "redirects back to the redirect_uri with a valid authorization code for the client" do
      response.status.should == 302
      code = Addressable::URI.parse(response.location).query_values["code"]
      code.should_not be_nil
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.should_not be_nil
      found.authorization.client.should == @client
      found.authorization.resource_owner.should == @owner
      found.should_not be_expired
    end
  end

  describe "Granting a code with a scope" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes', :scope => 'periscope')
    end

    it "includes the scope in the granted authorization" do
      code = Addressable::URI.parse(response.location).query_values["code"]
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.authorization.scope.should == 'periscope'
    end
  end

  describe "Granting a code with custom authorization length" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      env['oauth2.authorization_request'].grant! ExampleResourceOwner.first, 5.years.from_now
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'Yes', :five_years => 'true')
    end

    it "redirects with an authorization code linked to the extended authorization" do
      code = Addressable::URI.parse(response.location).query_values["code"]
      found = OAuth2::Provider.authorization_code_class.find_by_code(code)
      found.authorization.expires_at.should eql(5.years.from_now)
    end
  end

  describe "Denying a code" do
    action do |env|
      request = Rack::Request.new(env)
      env['oauth2.authorization_request'] ||= OAuth2::Provider::Rack::AuthorizationCodeRequest.new(request.params)
      env['oauth2.authorization_request'].deny!
    end

    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'No')
    end

    redirects_back_with_error 'access_denied'
  end
end