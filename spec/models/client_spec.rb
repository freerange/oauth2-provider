require 'spec_helper'

describe OAuth2::Provider.client_class do
  describe "any instance" do
    subject do
      OAuth2::Provider.client_class.new :name => 'client'
    end

    it "is valid with a name, oauth identifier and oauth secret" do
      subject.should be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      subject.should_not be_valid
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
      duplicate = OAuth2::Provider.client_class.create! :name => 'client2'
      subject.oauth_identifier = duplicate.oauth_identifier
      subject.should_not be_valid
    end

    it "allows any grant type (custom subclasses can override this)" do
      subject.allow_grant_type?('password').should be_true
      subject.allow_grant_type?('authorization_code').should be_true
      subject.allow_grant_type?('client_credentials').should be_true
    end
  end

  describe "a new instance" do
    subject do
      OAuth2::Provider.client_class.new :name => 'client'
    end

    it "uses .unique_random_token to assign random oauth identifier and secret" do
      OAuth2::Provider.client_class.stubs(:unique_random_token).with(:oauth_identifier).returns('random-identifier')
      OAuth2::Provider.client_class.stubs(:unique_random_token).with(:oauth_secret).returns('random-secret')
      subject.oauth_identifier.should eql('random-identifier')
      subject.oauth_secret.should eql('random-secret')
    end

    it "returns nil when to_param called" do
      subject.to_param.should be_nil
    end
  end

  describe "a saved instance" do
    subject do
      OAuth2::Provider.client_class.create! :name => 'client'
    end

    it "returns oauth_identifer when to_param called" do
      subject.to_param.should == subject.oauth_identifier
    end

    it "is findable by calling from_param with its oauth_identifier" do
      subject.should == OAuth2::Provider.client_class.from_param(subject.oauth_identifier)
    end
  end

  describe "#allow_redirection?(uri)" do
    describe "on a client with an oauth_redirect_uri" do
      subject do
        OAuth2::Provider.client_class.new :name => 'client', :oauth_redirect_uri => "http://valid.example.com/any/path"
      end

      it "returns true if hosts match" do
        subject.allow_redirection?("http://valid.example.com/another/path").should be_true
      end

      it "returns false if hosts are different match" do
        subject.allow_redirection?("http://invalid.example.com/another/path").should be_false
      end

      it "returns false if the provided uri isn't a valid uri" do
        subject.allow_redirection?("a-load-of-rubbish").should be_false
      end
    end
    
    describe "on a client with an empty oauth_redirect_uri" do
      subject do
        OAuth2::Provider.client_class.new :name => 'client', :oauth_redirect_uri => ""
      end

      it "always returns true" do
        subject.allow_redirection?("http://anything.example.com/any/path").should be_true
      end

      it "returns false if the provided uri isn't a valid uri" do
        subject.allow_redirection?("a-load-of-rubbish").should be_false
      end
    end

    describe "on a client without an oauth_redirect_uri" do
      subject do
        OAuth2::Provider.client_class.new :name => 'client'
      end

      it "always returns true" do
        subject.allow_redirection?("http://anything.example.com/any/path").should be_true
      end

      it "returns false if the provided uri isn't a valid uri" do
        subject.allow_redirection?("a-load-of-rubbish").should be_false
      end
    end
  end
end
