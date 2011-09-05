require 'spec_helper'

describe OAuth2::Provider::Rack::AuthenticationResponses do
  class Request
    include OAuth2::Provider::Rack::AuthenticationResponses
  end

  subject do
    Request.new
  end

  describe '#invalid_request!' do
    it 'throws 400 response with WWW-Authenticate header indicating invalid_token' do
      subject.expects(:throw_response!).with(
        400,
        {'WWW-Authenticate' => 'Bearer realm="OAuth2" error="invalid_request"'}
      )
      subject.invalid_request!
    end

    it 'includes description in response when provided' do
      subject.expects(:throw_response!).with(
        400,
        {'WWW-Authenticate' => 'Bearer realm="OAuth2" error="invalid_request" error_description="A description"'}
      )
      subject.invalid_request! 'A description'
    end
  end

  describe '#invalid_token!' do
    it 'throws 401 response with WWW-Authenticate header indicating invalid_token' do
      subject.expects(:throw_response!).with(
        401,
        {'WWW-Authenticate' => 'Bearer realm="OAuth2" error="invalid_token"'}
      )
      subject.invalid_token!
    end

    it 'includes description in response when provided' do
      subject.expects(:throw_response!).with(
        401,
        {'WWW-Authenticate' => 'Bearer realm="OAuth2" error="invalid_token" error_description="A description"'}
      )
      subject.invalid_token! 'A description'
    end
  end
end
