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
    else
      json = {
        error: 'invalid_grant',
        error_description: 'grant_type is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
  end

  private def client_credentials_token
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: "client_id or client_secret is invalid"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    token = consumer.tokens.create
    token.set_as_client_credentials
    render(json: token.client_credentials_token_json.merge(params[:state] ? { state: params[:state] } : {}))
  end

  private def authorization_code_token
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: "client_id or client_secret is invalid"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    token = Token.find_by(consumer: consumer, grant: 'authorization_code', code: params[:code], user: current_user)
    if token.redirect_uri.uri != params[:redirect_uri]
      json = {
        error: 'invalid_request',
        error_description: 'redirect_uri is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    token.set_tokens_for_authorization_code
    render(json: token.authorization_code_token_json.merge(params[:state] ? { state: params[:state] } : {}))
  end

  private def refresh_token
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = Token.find_by(consumer: consumer, grant: 'authorization_code', refresh_token: params[:refresh_token])
    token.set_refreshed_access_token
    render(json: token.refresh_token_json.merge(params[:state] ? { state: params[:state] } : {}))
  end
end
