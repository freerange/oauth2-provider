require 'bundler/setup'
require 'rails/all'
require 'rspec/rails'

require 'oauth2-provider'

Rails.env = "test"

module OAuth2
  class Application < Rails::Application
    config.root = File.dirname(__FILE__)
    paths.config.database = "database.yml"
    paths.log = File.expand_path("../../log/test.log", __FILE__)
  end
end

OAuth2::Application.initialize!

require File.expand_path("../schema.rb", __FILE__)
require 'timecop'
require 'yajl'

# Used as a resource owner
class Account < ActiveRecord::Base
  def self.authenticate_with_username_and_password(*args)
    find_by_username_and_password(*args)
  end
end

class ApplicationController < ActionController::Base
end

OAuth2::Application.routes.draw do
  match "/oauth/authorize", :to => 'client_app/authorization_codes#new'
  match "/oauth/access_token", :to => 'o_auth2/provider/access_tokens#create'
end

module OAuth2::Provider::RSpecMacros
  extend ActiveSupport::Concern

  def json_from_response
    @json_from_response ||= begin
      response.content_type.should == Mime::JSON
      Yajl::Parser.new.parse(response.body)
    end
  end

  module ClassMethods
    def responds_with_json_error(name, options = {})
      it %{responds with json: {"error": "#{name}"}, status: #{options[:status]}} do
        response.status.should == options[:status]
        json_from_response.should == {"error" => name}
      end
    end
  end
end

RSpec.configure do |config|
  config.before :each do
    Timecop.freeze
  end

  config.after :each do
    Timecop.return
  end

  config.include OAuth2::Provider::RSpecMacros
end