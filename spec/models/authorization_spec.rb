require 'spec_helper'

describe OAuth2::Provider.authorization_class do
  describe "any instance" do
    subject do
      result = OAuth2::Provider.authorization_class.new :client => create_client
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

  describe "a new instance" do
    subject do
      OAuth2::Provider.authorization_class.new
    end

    it "has no expiry time by default" do
      subject.expires_at.should be_nil
    end
  end

  describe "after being persisted and restored" do
    before :each do
      @client = create_client
      @owner = create_resource_owner
      @original = OAuth2::Provider.authorization_class.create!(:client => @client, :resource_owner => @owner, :expires_at => 1.year.from_now)
    end

    subject do
      OAuth2::Provider.authorization_class.find(@original.id)
    end

    it "remembers client" do
      subject.client.should eql(@client)
    end

    it "remembers resource owner" do
      subject.resource_owner.should eql(@owner)
    end
  end

  describe "obtain all authorizations for a resource owner" do
    before :each do
      @client = create_client
      @owner = create_resource_owner
      @authorization = OAuth2::Provider.authorization_class.create!(:client => @client, :resource_owner => @owner, :expires_at => 1.year.from_now)
    end

    subject do
      OAuth2::Provider.authorization_class.all_for(@owner)
    end

    it "returns correct number of authorizations" do
      subject.count.should eql(1)
    end

    it "should hold information on the authorized client" do
      subject[0].client.should eql(@client)
    end
  end

  describe ".allowing(client, owner, scope)" do
    before :each do
      @client = create_client
      @owner = create_resource_owner
      @scope = "any-scope"
      @authorization = OAuth2::Provider.authorization_class.create!(
        :client => @client,
        :resource_owner => @owner,
        :scope => @scope,
        :expires_at => 1.hour.from_now
      )
    end

    it "returns existing authorizations for the given client, owner and scope" do
      results = OAuth2::Provider.authorization_class.allowing(@client, @owner, @scope).to_a
      results.should eql([@authorization])
    end

    it "doesn't return authorizations where client is different" do
      results = OAuth2::Provider.authorization_class.allowing(create_client, @owner, @scope).to_a
      results.should eql([])
    end

    it "doesn't return authorizations where owner is different" do
      results = OAuth2::Provider.authorization_class.allowing(@client, create_resource_owner, @scope).to_a
      results.should eql([])
    end

    it "doesn't return authorizations where scope is different" do
      results = OAuth2::Provider.authorization_class.allowing(@client, @owner, 'another-scope').to_a
      results.should eql([])
    end

    it "doesn't return expired authorizations" do
      Timecop.travel 4.hours.from_now
      results = OAuth2::Provider.authorization_class.allowing(@client, @owner, @scope).to_a
      results.should eql([])
    end
  end

  describe "#revoke" do
    subject do
      OAuth2::Provider.authorization_class.create! :client => create_client
    end

    it "destroys itself" do
      subject.revoke
      subject.should be_destroyed
    end

    it "destroys any related authorization codes" do
      subject.authorization_codes.create! :redirect_uri => 'https://example.com'
      subject.revoke
      subject.authorization_codes.should be_empty
    end

    it "destroys any related access tokens" do
      subject.access_tokens.create!
      subject.revoke
      subject.access_tokens.should be_empty
    end
  end
end