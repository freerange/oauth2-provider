require 'spec_helper'

describe OAuth2::Provider::AccessToken do
  describe "any instance" do
    subject do
      OAuth2::Provider::AccessToken.new :client => OAuth2::Provider::Client.new
    end

    it "is valid with a client, expiry time and access token" do
      subject.expires_at.should_not be_nil
      subject.access_token.should_not be_nil

      subject.should be_valid
    end

    it "is invalid without an access token" do
      subject.access_token = nil
      subject.should_not be_valid
    end

    it "is invalid without a client" do
      subject.client = nil
      subject.should_not be_valid
    end

    it "is invalid when expires_at isn't set" do
      subject.expires_at = nil
      subject.should_not be_valid
    end

    it "returns time in seconds until expiry when expires_in called" do
      subject.expires_at = 60.minutes.from_now
      subject.expires_in.should == (60 * 60)
    end

    it "returns 0 for expired_in when already expired" do
      subject.expires_at = 60.minutes.ago
      subject.expires_in.should == 0
    end

    it "include expires_in and access token as JSON format" do
      subject.as_json.should == {"expires_in" => subject.expires_in, "access_token" => subject.access_token}
    end

    it "has a given scope, if scope string includes scope" do
      subject.scope = "first second third"
      subject.should have_scope("first")
      subject.should have_scope("second")
      subject.should have_scope("third")
    end

    it "doesn't have a given scope, if scope string doesn't scope" do
      subject.scope = "first second third"
      subject.should_not have_scope("fourth")
    end
  end

  describe "a new instance" do
    subject do
      OAuth2::Provider::AccessToken.new
    end

    it "is assigned a randomly generated access token" do
      subject.access_token.should_not be_nil
      OAuth2::Provider::AccessToken.new.access_token.should_not be_nil
      subject.access_token.should_not == OAuth2::Provider::AccessToken.new.access_token
    end

    it "expires in 1 month by default" do
      subject.expires_at.should == 1.month.from_now
    end
  end
end