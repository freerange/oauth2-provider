require 'spec_helper'

describe OAuth2::Provider::Models::RandomToken do
  describe ".unique_random_token(attribute)" do
    let :model do
      OAuth2::Provider.client_class
    end

    it "uses .random_token to generate a random token" do
      model.stubs(:random_token).returns('random-token')
      model.unique_random_token(:oauth_identifier).should eql('random-token')
    end

    it "calls .random_token repeatedly until unused token found" do
      m1 = model.create! :name => 'anything'
      m2 = model.create! :name => 'ignore'
      model.stubs(:random_token).returns(m1.oauth_identifier).then.returns(m2.oauth_identifier).then.returns('3rd-random-token')
      model.unique_random_token(:oauth_identifier).should eql('3rd-random-token')
    end

    it "only regards tokens used for same attribute as used" do
      m1 = model.create! :name => 'anything'
      model.stubs(:random_token).returns(m1.oauth_identifier).then.returns('2nd-random-token')
      model.unique_random_token(:oauth_secret).should eql(m1.oauth_identifier)
    end
  end
end