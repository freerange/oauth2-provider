require 'spec_helper'

describe OAuth2::Provider::Rack::Middleware do
  subject do
    ::OAuth2::Provider::Rack::Middleware.new(main_app)
  end

  def app
    subject
  end

  describe "in general" do
    let :main_app do
      Proc.new do
        [200, {'Content-Type' => 'text/plain'}, ['Apptastic']]
      end
    end

    it "passes requests to /oauth/access_token to #handle_access_token_request" do
      subject.expects(:handle_access_token_request).returns(
        [418, {'Content-Type' => 'text/plain'}, ['Short and stout']]
      )
      get "/oauth/access_token"
      response.status.should eql(418)
      response.body.should eql('Short and stout')
    end

    it "passes other requests to the main app" do
      get "/any/other/path"
      response.status.should eql(200)
      response.body.should eql('Apptastic')
    end

    describe "with access_token_path configured to /api/oauth/access_token" do
      before(:each) do
        OAuth2::Provider.configure do |config|
          config.access_token_path = '/api/oauth/access_token'
        end
      end

      it "passes requests to /api/oauth/access_token to #handle_access_token_request" do
        subject.expects(:handle_access_token_request).returns(
          [418, {'Content-Type' => 'text/plain'}, ['Short and stout']]
        )
        get "/api/oauth/access_token"
        response.status.should eql(418)
        response.body.should eql('Short and stout')
      end

      after(:each) do
        OAuth2::Provider.configure do |config|
          config.access_token_path = '/oauth/access_token'
        end
      end
    end
  end

  describe "when main app throws :oauth2 response" do
    let :main_app do
      Proc.new do
        throw :oauth2, [418, {'Content-Type' => 'text/plain'}, ['Teapot']]
      end
    end

    it "uses thrown response" do
      get "/any/path"
      response.status.should eql(418)
      response.body.should eql('Teapot')
    end
  end
end
