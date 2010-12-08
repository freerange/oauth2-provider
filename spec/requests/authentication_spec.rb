require 'spec_helper'

class ExampleController < ActionController::Base
  authenticate_with_oauth :only => :protected
  authenticate_with_oauth :scope => 'omnipotent', :only => :protected_by_scope

  def protected
    render :text => "Success"
  end

  def protected_by_scope
    render :text => "Success"
  end
end

describe "A request for a protected resource" do
  before :all do
    OAuth2::Application.routes.draw do
      match "/protected", :to => "example#protected"
    end
  end

  before :each do
    @token = create_access_token(:authorization => create_authorization(:scope => "protected write"))
  end

  describe "with no token passed" do
    before :each do
      get "/protected"
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2'
  end

  describe "with a token passed as an oauth_token parameter" do
    before :each do
      get "/protected", :oauth_token => @token.access_token
    end

    it "is successful" do
      response.should be_successful
    end

    it "makes the access token available to the requested action" do
      response.body.should == "Success"
    end
  end

  describe "with a token passed in an Authorization header" do
    before :each do
      get "/protected", {}, {"HTTP_AUTHORIZATION" => "OAuth #{@token.access_token}"}
    end

    it "is successful" do
      response.should be_successful
    end

    it "makes the access token available to the requested action" do
      response.body.should == "Success"
    end
  end

  describe "with tokens passed in both the Authorization header and oauth_token parameter" do
    before :each do
      get "/protected", {:oauth_token => @token.access_token}, {"HTTP_AUTHORIZATION" => "OAuth #{@token.access_token}"}
    end

    responds_with_json_error 'invalid_request', :status => 400
  end

  describe "with an invalid token" do
    before :each do
      get "/protected", :oauth_token => 'invalid-token'
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end

  describe "with an expired token that can be refreshed" do
    before :each do
      @token.update_attributes(:expires_at => 1.day.ago)
      get "/protected", :oauth_token => @token.access_token
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end

  describe "with an expired token that can't be refreshed" do
    before :each do
      @token.update_attributes(:expires_at => 1.day.ago, :refresh_token => nil)
      get "/protected", :oauth_token => @token.access_token
    end

    responds_with_status 401
    responds_with_header 'WWW-Authenticate', 'OAuth2 error="invalid_token"'
  end
end

describe "A request for a protected resource requiring a specific scope" do
  before :all do
    OAuth2::Application.routes.draw do
      match "/protected_by_scope", :to => "example#protected_by_scope"
    end
  end

  before :each do
    @token = create_access_token(:authorization => create_authorization(:scope => "omnipotent admin"))
    @insufficient_token = create_access_token(:authorization => create_authorization(:scope => "impotent admin"))
  end

  describe "made with a token with sufficient scope" do
    before :each do
      get '/protected_by_scope', :oauth_token => @token.access_token
    end

    it "is successful" do
      response.should be_successful
    end
  end

  describe "made with a token with insufficient scope" do
    before :each do
      get '/protected_by_scope', :oauth_token => @insufficient_token.access_token
    end

    responds_with_json_error 'insufficient_scope', :status => 403
  end
end