require 'bundler/setup'
require 'rails/all'
require 'rspec/rails'

require 'oauth2-provider'
require 'mongoid'

Rails.env = "test"

module OAuth2
  class Application < Rails::Application
    config.root = File.dirname(__FILE__)
    paths.config.database = "database.yml"
    paths.log = File.expand_path("../../log/test.log", __FILE__)
    config.secret_token = "something secret and very very long are you happy now are you?"
    config.oauth2_provider.backend = ENV["BACKEND"].to_sym if ENV["BACKEND"]
    config.oauth2_provider.backend ||= :activerecord
    config.oauth2_provider.resource_owner_class_name = 'ExampleResourceOwner'
  end
end

OAuth2::Application.initialize!
require 'timecop'
require 'yajl'

if OAuth2::Provider.backend == :activerecord
  require File.expand_path("../schema.rb", __FILE__)

  class ExampleResourceOwner < ActiveRecord::Base
    def self.authenticate_with_username_and_password(*args)
      find_by_username_and_password(*args)
    end
  end
else
  class ExampleResourceOwner
    include Mongoid::Document

    field :username
    field :password

    references_many :access_grants, :class_name => "OAuth2::Provider::Models::Mongoid::AccessGrant"

    def self.authenticate_with_username_and_password(username, password)
      where(:username => username, :password => password).first
    end
  end

  class OAuth2::Provider::Models::Mongoid::AccessGrant
    referenced_in :resource_owner, :class_name => "OAuth2::Provider::Models::Mongoid::Client"
  end
end

class ApplicationController < ActionController::Base
end

@settings = YAML.load(ERB.new(File.new(File.expand_path("../mongoid.yml", __FILE__)).read).result)
Mongoid.configure do |config|
  config.from_hash(@settings["test"])
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

    def redirects_back_with_error(name)
      it %{redirects back with error '#{name}'} do
        response.status.should == 302
        error = Addressable::URI.parse(response.location).query_values["error"]
        error.should == name
      end
    end
  end
end

module OAuth2::Provider::ModelFactories
  def build_client(attributes = {})
    OAuth2::Provider.client_class.new({:name => 'client'}.merge(attributes))
  end

  def create_client(attributes = {})
    build_client(attributes).tap do |c|
      c.save!
    end
  end

  def build_access_grant(attributes = {})
    OAuth2::Provider.access_grant_class.new({
      :client => build_client
    }.merge(attributes))
  end

  def create_access_grant(attributes = {})
    build_access_grant({:client => create_client}.merge(attributes)).tap do |ag|
      ag.save!
    end
  end

  def build_authorization_code(attributes = {})
    OAuth2::Provider.authorization_code_class.new({
      :redirect_uri => "https://client.example.com/callback",
      :access_grant => build_access_grant
    }.merge(attributes))
  end

  def create_authorization_code(attributes = {})
    build_authorization_code({:access_grant => create_access_grant}.merge(attributes)).tap do |ac|
      ac.save!
    end
  end

  def build_access_token(attributes = {})
    OAuth2::Provider.access_token_class.new({
      :access_grant => build_access_grant
    }.merge(attributes))
  end

  def create_access_token(attributes = {})
    build_access_token({:access_grant => create_access_grant}.merge(attributes)).tap do |ac|
      ac.save!
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
  config.include OAuth2::Provider::ModelFactories
end