require 'spec_helper'

describe OAuth2::Provider::AuthorizationCodesSupport do
  controller do
    include OAuth2::Provider::AuthorizationCodesSupport

    before_filter :block_invalid_authorization_code_requests

    def new
      render :text => 'Success'
    end

    def create
      # It's up to individual apps to decide how codes are granted (including which action
      # should be responsible for granting).  The solution here is deliberately naive.
      if params["submit"] == "Yes"
        grant_authorization_code
      else
        deny_authorization_code
      end
    end
  end

  before :each do
    @client = OAuth2::Provider::Models::ActiveRecord::Client.create!
    @valid_params = {
      :client_id => @client.oauth_identifier,
      :redirect_uri => "https://redirect.example.com/callback"
    }
  end

  describe "Any request with a client_id and redirect_uri" do
    before :each do
      get :new, @valid_params
    end

    it "is successful" do
      response.status.should == 200
    end
  end

  # TODO the responses here are rubbish; they really need improving

  describe "Any request without a client_id" do
    before :each do
      get :new, @valid_params.except(:client_id)
    end

    it "returns 404" do
      response.status.should == 404
    end
  end

  describe "Any request without a redirect_uri" do
    before :each do
      get :new, @valid_params.except(:redirect_uri)
    end

    it "returns 404" do
      response.status.should == 404
    end
  end

  describe "Any request without an unknown client id" do
    before :each do
      get :new, @valid_params.merge(:client_id => 'unknown')
    end

    it "returns 404" do
      response.status.should == 404
    end
  end

  describe "Granting a code" do
    before :each do
      post :create, @valid_params.merge(:submit => 'Yes')
    end

    it "redirects back to the redirect_uri with a valid authorization code for the client" do
      response.status.should == 302
      code = Addressable::URI.parse(response.location).query_values["code"]
      code.should_not be_nil
      found = OAuth2::Provider::Models::ActiveRecord::AuthorizationCode.find_by_code(code)
      found.should_not be_nil
      found.access_grant.client.should == @client
      found.should_not be_expired
    end
  end

  describe "Denying a code" do
    before :each do
      post :create, @valid_params.merge(:submit => 'No')
    end

    it "redirects back to the redirect_uri without an authorization code" do
      response.status.should == 302
      code = Addressable::URI.parse(response.location).query_values["code"]
      code.should be_nil
    end
  end
end
