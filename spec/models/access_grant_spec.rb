require 'spec_helper'

describe OAuth2::Provider::AccessGrant do
  describe "any instance" do
    subject do
      OAuth2::Provider::AccessGrant.new :client => build_client
    end

    it "is valid with a client" do
      subject.client.should_not be_nil
      subject.should be_valid
    end

    it "is invalid without a client" do
      subject.client = nil
      subject.should_not be_valid
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
end