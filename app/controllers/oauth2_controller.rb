class OAuth2Controller < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider

  private def get_service_provider
    @sp = ServiceProvider.find(params[:service_provider_id])
  end

  def authorize
    if params[:response_type] == 'token'
      implicit_token
    elsif params[:response_type] == 'code'
      authorization_code
    end
  end

  private def implicit_token
    consumer = Consumer.includes(:redirect_uris).find_by(client_id_key: params[:client_id], redirect_uris: { uri: params[:redirect_uri] })
    rejected_scopes = params[:scope].split(' ').select { |given_scope| !consumer.service_provider.scopes.find { |scope| scope.name == given_scope } }
    unless rejected_scopes.empty?
      redirect_params = {
        error_description: "Unknown scopes: #{rejected_scopes.join(', ')}"
      }
      return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
    end
    token = consumer.tokens.create
    token.set_as_implicit(params[:scope].split(' '))
    redirect_params = {
      access_token: token.access_token,
      token_type: 'bearer',
      expires_in: 3600,
      scope: 'basic',
      state: params[:state]
    }
    redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
  end

  private def authorization_code
    consumer = Consumer.includes(:redirect_uris).find_by(client_id_key: params[:client_id], redirect_uris: { uri: params[:redirect_uri] })
    rejected_scopes = params[:scope].split(' ').select { |given_scope| !consumer.service_provider.scopes.find { |scope| scope.name == given_scope } }
    unless rejected_scopes.empty?
      redirect_params = {
        error_description: "Unknown scopes: #{rejected_scopes.join(', ')}"
      }
      return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
    end
    if current_user
      @token = consumer.tokens.find_or_create_by(grant: 'authorization_code', user: current_user)
      @token.set_as_authorization_code(params[:scope].split(' '))
      @token.state = params[:state]
      @token.redirect_uri = RedirectURI.find_by(consumer: consumer, uri: params[:redirect_uri])
      @token.save
      @state = params[:state]
      @scopes = consumer.service_provider.scopes.select { |s| params[:scope].split(' ').include?(s.name) }
      render(:authorize)
    else
      render(:authorize_login)
    end
  end

  def authorize_redirect_with_code
    consumer = Consumer.includes(:redirect_uris).find_by(client_id_key: params[:client_id], redirect_uris: { uri: params[:redirect_uri] })
    token = consumer.tokens.find_by(grant: 'authorization_code', user: current_user)
    redirect_params = {
      code: token.code,
      state: token.state
    }
    redirect_to("#{token.redirect_uri.uri}?#{redirect_params.to_param}")
  end

  def token
    if params[:grant_type] == 'client_credentials'
      client_credentials_token
    end
  end

  private def client_credentials_token
    consumer = Consumer.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = consumer.tokens.create
    token.set_as_client_credentials
    render(:json => {
      expires_in: consumer.seconds_to_expire,
      status: 'success',
      access_token: token.access_token,
      token_type: token.token_type
    })
  end
end
