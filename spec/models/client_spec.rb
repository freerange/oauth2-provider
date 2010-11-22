require 'spec_helper'

describe OAuth2::Provider::Client do
  describe "any instance" do
    subject do
      OAuth2::Provider::Client.new
    end

    it "is invalid without an oauth identifier" do
      subject.oauth_identifier = nil
      subject.should_not be_valid
    end

    it "is invalid without an oauth secret" do
      subject.oauth_secret = nil
      subject.should_not be_valid
    end

    it "is invalid if oauth_identifier not unique" do
      duplicate = OAuth2::Provider::Client.create!
      subject.oauth_identifier = duplicate.oauth_identifier
      subject.should_not be_valid
    end

    it "allows any grant type (custom subclasses can override this)" do
      subject.allow_grant_type?('password').should be_true
      subject.allow_grant_type?('authorization_code').should be_true
    end
  end

  describe "a new instance" do
    subject do
      OAuth2::Provider::Client.new
    end

    it "is assigned a randomly generated oauth identifier" do
      subject.oauth_identifier.should_not be_nil
      OAuth2::Provider::Client.new.oauth_identifier.should_not be_nil
      subject.oauth_identifier.should_not == OAuth2::Provider::Client.new.oauth_identifier
    end

    it "is assigned a randomly generated oauth secret" do
      subject.oauth_secret.should_not be_nil
      OAuth2::Provider::Client.new.oauth_secret.should_not be_nil
      subject.oauth_secret.should_not == OAuth2::Provider::Client.new.oauth_secret
    end

    it "returns nil when to_param called" do
      subject.to_param.should be_nil
    end
  end

  describe "a saved instance" do
    subject do
      OAuth2::Provider::Client.create!
    end

    it "returns oauth_identifer when to_param called" do
      subject.to_param.should == subject.oauth_identifier
    end

    it "is findable by calling from_param with its oauth_identifier" do
      subject.should == OAuth2::Provider::Client.from_param(subject.oauth_identifier)
    end
  end
end