require 'spec_helper'

describe OAuth2::Provider::Rack::BearerTokenRequest do
  let :url do
    "http://example.com:8080/"
  end

  let :headers do
    {}
  end

  let :env do
    Rack::MockRequest.env_for(url, headers)
  end

  let :valid_token do
    create_access_token
  end

  let :expired_token do
    create_access_token :expires_at => 1.day.ago
  end

  subject do
    OAuth2::Provider::Rack::BearerTokenRequest.new(env)
  end

  describe '#access_token_from_param' do
    describe 'with access_token parameter' do
      let :url do
        "http://example.com:8080?access_token=1234abcd"
      end

      it 'returns token value' do
        subject.access_token_from_param.should eql('1234abcd')
      end
    end

    describe 'without parameter' do
      it 'returns nil' do
        subject.access_token_from_param.should be_nil
      end
    end
  end

  describe '#access_token_from_header' do
    describe 'with authorization header for Bearer scheme' do
      let :headers do
        {'HTTP_AUTHORIZATION' => 'Bearer 1234abcd'}
      end

      it 'returns token value' do
        subject.access_token_from_header.should eql('1234abcd')
      end
    end

    describe 'without authorization header' do
      it 'returns nil' do
        subject.access_token_from_header.should be_nil
      end
    end

    describe 'with authorization header for different scheme' do
      let :headers do
        {'HTTP_AUTHORIZATION' => 'Basic 1234abcd'}
      end

      it 'returns nil' do
        subject.access_token_from_header.should be_nil
      end
    end
  end

  describe '#access_token' do
    it 'returns #access_token_from_header when present' do
      subject.stubs(:access_token_from_header).returns('9876efgh')
      subject.access_token.should eql('9876efgh')
    end

    it 'returns #access_token_from_param when present' do
      subject.stubs(:access_token_from_param).returns('9876efgh')
      subject.access_token.should eql('9876efgh')
    end

    it 'returns nil when token not found in either param or header' do
      subject.access_token.should be_nil
    end
  end

  describe '#has_access_token?' do
    it 'is true if #access_token returns something' do
      subject.stubs(:access_token).returns('anything')
      subject.has_access_token?.should be_true
    end

    it 'is true if #access_token returns nil' do
      subject.has_access_token?.should be_false
    end
  end

  describe '#validate_access_token!' do
    describe 'with a valid access token' do
      let :url do
        "http://example.com:8080?access_token=" + valid_token.access_token
      end

      it 'returns successfully' do
        lambda { subject.validate_access_token! }.should_not throw_symbol
      end
    end

    describe 'with an invalid access token' do
      let :url do
        "http://example.com:8080?access_token=" + 'invalid'
      end

      it 'responds with invalid_token' do
        subject.expects(:invalid_token!)
        subject.validate_access_token!
      end
    end

    describe 'with an expired access token' do
      let :url do
        "http://example.com:8080?access_token=" + expired_token.access_token
      end

      it 'responds with invalid_token' do
        subject.expects(:invalid_token!).with('Access token has expired')
        subject.validate_access_token!
      end
    end

    describe 'with matching tokens in header and params' do
      let :url do
        "http://example.com:8080?access_token=" + valid_token.access_token
      end

      let :headers do
        {'HTTP_AUTHORIZATION' => "Bearer #{valid_token.access_token}"}
      end

      it 'responds with invalid_request' do
        subject.expects(:invalid_request!).with('Access token provided as both header and parameter')
        subject.validate_access_token!
      end
    end
  end

  describe 'using a custom parameter name' do
    before do
      OAuth2::Provider::Rack::BearerTokenRequest.parameter_name = 'custom_name'
    end

    describe '#access_token_from_param' do
      describe 'with access_token parameter' do
        let :url do
          "http://example.com:8080?access_token=1234abcd"
        end

        it 'returns nil' do
          subject.access_token_from_param.should be_nil
        end
      end

      describe 'with custom named parameter' do
        let :url do
          "http://example.com:8080?custom_name=1234abcd"
        end

        it 'returns token' do
          subject.access_token_from_param.should eql('1234abcd')
        end
      end
    end

    after do
      OAuth2::Provider::Rack::BearerTokenRequest.parameter_name = 'access_token'
    end
  end

  describe 'using a custom authorization scheme name' do
    before do
      OAuth2::Provider::Rack::BearerTokenRequest.authorization_scheme_name = 'Custom'
    end

    describe '#access_token_from_header' do
      describe 'with authorization header for Bearer scheme' do
        let :headers do
          {'HTTP_AUTHORIZATION' => 'Bearer 1234abcd'}
        end

        it 'returns nil' do
          subject.access_token_from_header.should be_nil
        end
      end

      describe 'with authorization header for custom scheme' do
        let :headers do
          {'HTTP_AUTHORIZATION' => 'Custom 1234abcd'}
        end

        it 'returns token' do
          subject.access_token_from_header.should eql('1234abcd')
        end
      end
    end

    after do
      OAuth2::Provider::Rack::BearerTokenRequest.parameter_name = 'Bearer'
    end
  end
end