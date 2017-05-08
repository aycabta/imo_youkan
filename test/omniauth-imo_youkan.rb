require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ImoYoukan < OmniAuth::Strategies::OAuth2
      def callback_url
        full_host + script_name + callback_path
      end

      # Give your strategy a name.
      option :name, 'imo_youkan'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        site: 'http://localhost:3000/1',
        authorize_url: 'http://localhost:3000/1/oauth2/authorize',
        token_url: 'http://localhost:3000/1/oauth2/token'
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
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
        @raw_info ||= access_token.get('/oauth2/introspect').parsed
      end
    end
  end
end
