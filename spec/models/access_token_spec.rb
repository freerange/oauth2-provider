require 'spec_helper'

describe OAuth2::Provider.access_token_class do
  describe "any instance" do
    subject do
      OAuth2::Provider.access_token_class.new :authorization => build_authorization
    end

    it "is valid with an access grant, expiry time and access token" do
      subject.expires_at.should_not be_nil
      subject.access_token.should_not be_nil
      subject.authorization.should_not be_nil

      subject.should be_valid
    end

    it "is invalid without an access token" do
      subject.access_token = nil
      subject.should_not be_valid
    end

    it "is invalid without an access grant" do
      subject.authorization = nil
      subject.should_not be_valid
    end

    it "is invalid if expires_at is later than the authorization's value" do
      subject.authorization.expires_at = 1.minute.from_now
      subject.expires_at = 10.minutes.from_now
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

    it "include expires_in, refresh_token and access token as JSON format" do
      subject.as_json.should == {"expires_in" => subject.expires_in, "access_token" => subject.access_token, "refresh_token" => subject.refresh_token}
    end

    it "include only expires_in and access token as JSON format if no refresh token set" do
      subject.refresh_token = nil
      subject.as_json.should == {"expires_in" => subject.expires_in, "access_token" => subject.access_token}
    end

    it "is refreshable, if it has a refresh token" do
      subject.refresh_token = 'abcd1234'
      subject.should be_refreshable
    end

    it "is not refreshable if it has no refresh token" do
      subject.refresh_token = nil
      subject.should_not be_refreshable
    end

    it "is not refreshable if it has a refresh token, but its authorization has expired" do
      subject.refresh_token = 'abcd1234'
      subject.authorization.expires_at = 60.minutes.ago
      subject.should_not be_refreshable
    end
  end

  describe "a new instance" do
    subject do
      OAuth2::Provider.access_token_class.new
    end

    it "uses .unique_random_token to assign random access and refresh tokens" do
      OAuth2::Provider.access_token_class.stubs(:unique_random_token).with(:access_token).returns('random-access-token')
      OAuth2::Provider.access_token_class.stubs(:unique_random_token).with(:refresh_token).returns('random-refresh-token')
      subject.access_token.should eql('random-access-token')
      subject.refresh_token.should eql('random-refresh-token')
    end

    it "expires in 1 month by default" do
      subject.expires_at.should == 1.month.from_now
    end
  end

  describe "refreshing an existing token" do
    subject do
      OAuth2::Provider.access_token_class.create! :authorization => create_authorization, :expires_at => 23.days.ago
    end

    it "returns a new access token with the same client, resource_owner and scope, but a new expiry time" do
      result = OAuth2::Provider.access_token_class.refresh_with(subject.refresh_token)
      result.should_not be_nil
      result.expires_at.should == 1.month.from_now
      result.authorization.should == subject.authorization
    end

    it "returns token with expires_at set to authorization.expires_at if validation would fail otherwise" do
      subject.authorization.update_attributes(:expires_at => 5.minutes.from_now)
      result = OAuth2::Provider.access_token_class.refresh_with(subject.refresh_token)
      result.expires_at.should == 5.minutes.from_now
    end

    it "returns nil if the provided token doesn't match" do
      OAuth2::Provider.access_token_class.refresh_with('wrong').should be_nil
    end

    it "returns nil if the existing refresh token is nil, whatever value is provided" do
      subject.update_attributes(:refresh_token => nil)
      OAuth2::Provider.access_token_class.refresh_with(nil).should be_nil
    end
  end

  describe "creating a token without expiry" do
    subject do
      token = OAuth2::Provider.access_token_class.create! :authorization => create_authorization
      token.expires_at = nil
      token.refresh_token = nil
      token
    end

    it "returns false when asked expires?" do
      subject.expired?.should == false
      subject.expires_in.should == nil
    end
  end
end