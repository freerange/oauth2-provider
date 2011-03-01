require 'bundler/setup'
require 'rack'
require 'rack/test'
require 'oauth2-provider'

require 'timecop'
require 'yajl'

backend = ENV["BACKEND"].to_sym if ENV["BACKEND"]
backend ||= :activerecord

if backend == :activerecord
  require 'active_record'

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "test.db"
  )

  require File.expand_path("../schema.rb", __FILE__)

  class ExampleResourceOwner < ActiveRecord::Base
    def self.authenticate_with_username_and_password(*args)
      find_by_username_and_password(*args)
    end
  end

  OAuth2::Provider.configure do |config|
    config.resource_owner_class_name = 'ExampleResourceOwner'
  end
else
  require 'mongoid'

  class ExampleResourceOwner
    include Mongoid::Document

    field :username
    field :password

    references_many :authorizations, :class_name => "OAuth2::Provider::Models::Mongoid::Authorization"

    def self.authenticate_with_username_and_password(username, password)
      where(:username => username, :password => password).first
    end
  end

  OAuth2::Provider.configure do |config|
    config.backend = :mongoid
    config.resource_owner_class_name = 'ExampleResourceOwner'
  end

  @settings = YAML.load(ERB.new(File.new(File.expand_path("../mongoid.yml", __FILE__)).read).result)
  Mongoid.configure do |config|
    config.from_hash(@settings["test"])
  end
end

require 'support/macros'
require 'support/factories'
require 'support/rack'

RSpec.configure do |config|
  config.before :each do
    Timecop.freeze
  end

  config.after :each do
    Timecop.return
  end

  config.include OAuth2::Provider::RSpec::Macros
  config.include OAuth2::Provider::RSpec::Factories
  config.include OAuth2::Provider::RSpec::Rack
end