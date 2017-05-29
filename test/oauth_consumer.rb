require 'rubygems'
require 'sinatra'
require 'omniauth'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ImoYoukan < OmniAuth::Strategies::OAuth2
      def callback_url
        full_host + script_name + callback_path
      end

      option :name, 'imo_youkan'

      option :client_options, {
        site: 'http://localhost:3000/1',
        authorize_url: 'http://localhost:3000/1/oauth2/authorize',
        token_url: 'http://localhost:3000/1/oauth2/token'
      }

      uid { raw_info['user']['uid'] }

      info do
        {
          name: raw_info['user']['name'],
          email: raw_info['user']['email']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        params = {
          client_id: @options[:client_id],
          client_secret: @options[:client_secret],
          token: access_token.token
        }
        @raw_info ||= access_token.post('/1/oauth2/introspect') { |req|
          req.params = params
        }.parsed
      end
    end
  end
end

configure do
  set :sessions, true
  set :inline_templates, true
  set :show_exceptions, :after_handler
end

use OmniAuth::Builder do
  provider(
    :imo_youkan,
    ENV['CLIENT_ID'], ENV['CLIENT_SECRET'],
    scope: ENV['SCOPE'])
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
