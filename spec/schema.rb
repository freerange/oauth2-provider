# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110323171649) do
  create_table 'accounts', :force => true do |t|
    t.string   'username'
    t.string   'password'
  end

  create_table 'oauth_clients', :force => true do |t|
    t.string   'oauth_identifier', :null => false
    t.string   'oauth_secret', :null => false
  end

  create_table 'oauth_authorization_codes', :force => true do |t|
    t.integer  'access_grant_id', :null => false
    t.string   'code',      :null => false
    t.datetime 'expires_at'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'redirect_uri'
  end

  create_table 'oauth_access_grants', :force => true do |t|
    t.integer  'client_id', :null => false
    t.integer  'account_id'
    t.string   'scope'
    t.datetime 'expires_at'
  end

  create_table 'oauth_access_tokens', :force => true do |t|
    t.integer  'access_grant_id', :null => false
    t.string   'access_token', :null => false
    t.string   'refresh_token'
    t.datetime 'expires_at'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end
end
