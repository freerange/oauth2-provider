require 'spec_helper'

class AuthorizationController < ActionController::Base
  include OAuth2::Provider::Rack::AuthorizationCodesSupport

  before_filter :block_invalid_authorization_code_requests

  def new
    render :text => 'Success'
  end

  def create
    # It's up to individual apps to decide how codes are granted (including which action
    # should be responsible for granting).  The solution here is deliberately naive.
    if params["submit"] == "Yes"
      if params["five_years"]
        grant_authorization_code nil, 5.years.from_now
      else
        grant_authorization_code
      end
    else
      deny_authorization_code
    end
  end
end

describe OAuth2::Provider::Rack::AuthorizationCodesSupport do
  before :all do
    OAuth2::Application.routes.draw do
      match "/oauth/authorize", :via => :get, :to => "authorization#new"
      match "/oauth/authorize", :via => :post, :to => "authorization#create"
    end
  end

  before :each do
    @client = OAuth2::Provider.client_class.create! :name => 'client'
    @valid_params = {
      :client_id => @client.oauth_identifier,
      :redirect_uri => "https://redirect.example.com/callback"
    }
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

    redirects_back_with_error 'invalid_request'
  end

  describe "Any request without a redirect_uri" do
    before :each do
      get '/oauth/authorize', @valid_params.except(:redirect_uri)
    end

    it "returns 400" do
      response.status.should == 400
    end
  end

  describe "Any request without an unknown client id" do
    before :each do
      get '/oauth/authorize', @valid_params.merge(:client_id => 'unknown')
    end

    redirects_back_with_error 'invalid_client'
  end

  describe "Granting a code" do
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
      found.should_not be_expired
    end
  end

  describe "Granting a code with custom authorization length" do
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
    before :each do
      post '/oauth/authorize', @valid_params.merge(:submit => 'No')
    end

    redirects_back_with_error 'access_denied'
  end
end
