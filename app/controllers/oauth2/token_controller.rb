class OAuth2::TokenController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider
  before_action :check_content_type, if: -> { request.post? }

  def create
    if params[:grant_type] == 'client_credentials'
      client_credentials_token
    elsif params[:grant_type] == 'authorization_code'
      authorization_code_token
    elsif params[:grant_type] == 'refresh_token'
      refresh_token
    end
  end

  private def client_credentials_token
    consumer = Consumer.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = consumer.tokens.create
    token.set_as_client_credentials
    render(json: token.client_credentials_token_json)
  end

  private def authorization_code_token
    consumer = Consumer.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = Token.joins(:redirect_uri).find_by(consumer: consumer, grant: 'authorization_code', code: params[:code], redirect_uris: { uri: params[:redirect_uri] })
    token.set_tokens_for_authorization_code
    render(json: token.authorization_code_token_json)
  end

  private def refresh_token
    consumer = Consumer.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = Token.find_by(consumer: consumer, grant: 'authorization_code', refresh_token: params[:refresh_token])
    token.set_refreshed_access_token
    puts token.refresh_token_json
    render(json: token.refresh_token_json)
  end
end