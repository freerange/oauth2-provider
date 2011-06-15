# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

OAuth2::Provider.client_class.create! :name => 'Example Client', :oauth_identifier => 'abcdefgh12345678', :oauth_secret => 'secret', :oauth_redirect_uri => 'http://localhost:9292/'

Account.create! :login => 'tomafro', :password => 'secret'