class OAuth2Controller < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider
  before_action :check_content_type, only: [:token, :authorize, :revoke, :introspect], if: -> { request.post? }

  private def get_service_provider
    @sp = ServiceProvider.find(params[:service_provider_id])
  end

  private def check_content_type
    unless request.content_type == 'application/x-www-form-urlencoded'
      json = {
        error: 'invalid_request',
        error_description: 'Request header validation failed.',
        error_details: {
          content_type: "#{request.content_type} is invalid, must be application/x-www-form-urlencoded"
        },
        status: 'error'
      }
      render(json: json, status: :bad_request)
    end
  end

  def authorize
    if params[:response_type].nil?
      json = {
        error: 'invalid_request',
        error_description: 'response_type is required'
      }
      render(status: :bad_request, json: json)
    else
      json = {
        error: 'unsupported_response_type',
        error_description: "#{params[:response_type]} is unknown"
      }
      render(status: :bad_request, json: json)
    end
  end

  def unauthorized
    redirect_params = {
      error: 'access_denied',
      error_description: 'Resource owner denied authorization'
    }
    redirect_params[:state] = params[:state] if params[:state]
    return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
  end

  def revoke
    # TODO checks each params separately and returns error
    token = Token.includes(:consumer).find_by(access_token: params[:token], consumers: { client_id_key: params[:client_id], client_secret: params[:client_secret] })
    if token
      token.access_token = nil
      token.save!
    end
    render(json: {})
  end

  def introspect
    # TODO checks each params separately and returns error
    token = Token.includes(:consumer).find_by(access_token: params[:token], consumers: { client_id_key: params[:client_id], client_secret: params[:client_secret] })
    if token
      if token.expires_in >= Time.now
        # TODO scope and others (username, email, redirect_uri, ...)
        render(json: { active: true })
      else
        render(json: { active: false })
      end
    else
      render(json: { active: false })
    end
  end

  def token
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
