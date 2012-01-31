require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'httparty'

CLIENT_ID = 'abcdefgh12345678'
CLIENT_SECRET = 'secret'
RESOURCE_HOST = 'http://localhost:3000'

enable :sessions

helpers do
  def redirect_uri
    "http://" + request.host_with_port + "/callback"
  end

  def access_token
    session[:access_token]
  end

  def get_with_access_token(path)
    HTTParty.get(RESOURCE_HOST + path, :query => {:oauth_token => access_token})
  end

  def authorize_url
    RESOURCE_HOST + "/oauth/authorize?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&redirect_uri=#{redirect_uri}"
  end
  
  def access_token_url
    RESOURCE_HOST + "/oauth/access_token"
  end

  def get_access_token(grant_type, additional_params={})
    params = {:client_id => CLIENT_ID,
              :client_secret => CLIENT_SECRET,
              :grant_type => grant_type}.merge(additional_params)
    response = HTTParty.post(access_token_url, :body => params)
    session[:access_token] = response["access_token"]
  end
end

get '/' do
  haml :home
end

get '/callback' do
  get_access_token("authorization_code",
                   {:code => params["code"],
                    :redirect_uri => redirect_uri})
  redirect '/account'
end

get '/account' do
  if access_token
    @resource_response = get_with_access_token("/account.json")
    haml :response
  else
    redirect authorize_url
  end
end

get '/login' do
  haml :login
end

post '/login' do
  get_access_token("password",
                   {:username => params["login"],
                    :password => params["password"]})
  redirect '/account'
end