require 'rubygems'
require 'sinatra'
require 'omniauth'
require_relative 'omniauth-imo_youkan'

configure do
  set :sessions, true
  set :inline_templates, true
  set :show_exceptions, :after_handler
end

use OmniAuth::Builder do
  provider(
    :imo_youkan,
    'client_id', 'client_secret', # TODO generate
    scope: 'basic great aaa')
end

get '/' do
  erb "<a href='/auth/imo_youkan'>Login with ImoYoukan</a><br>"
end

get '/auth/:provider/callback' do
  result = request.env['omniauth.auth']
  erb "<a href='/'>Top</a><br>
       <h1>#{params[:provider]}</h1>
       <pre>#{JSON.pretty_generate(result)}</pre>"
end
