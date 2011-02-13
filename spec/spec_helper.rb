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

    references_many :authorizations, :class_name => "OAuth2::Provider::Models::Mongoid::Authorization"

    def self.authenticate_with_username_and_password(username, password)
      where(:username => username, :password => password).first
    end
  end
end

class ApplicationController < ActionController::Base
end

@settings = YAML.load(ERB.new(File.new(File.expand_path("../mongoid.yml", __FILE__)).read).result)
Mongoid.configure do |config|
  config.from_hash(@settings["test"])
end

require 'support/macros'
require 'support/factories'

RSpec.configure do |config|
  config.before :each do
    Timecop.freeze
  end

  config.after :each do
    Timecop.return
  end

  config.include OAuth2::Provider::RSpec::Macros
  config.include OAuth2::Provider::RSpec::Factories
end