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
    token.state = params[:state]
    token.redirect_uri = RedirectURI.find_by(consumer: consumer, uri: params[:redirect_uri])
    token.save
    redirect_to(token.redirect_uri_to_implicit_token)
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
      session[:continued_url] = request.url
      render(:authorize_login)
    end
  end

  def authorize_redirect_with_code
    consumer = Consumer.includes(:redirect_uris).find_by(client_id_key: params[:client_id], redirect_uris: { uri: params[:redirect_uri] })
    token = consumer.tokens.find_by(grant: 'authorization_code', user: current_user)
    redirect_to(token.redirect_uri_to_authorize_redirect_with_code)
  end

  def token
    if params[:grant_type] == 'client_credentials'
      client_credentials_token
    elsif params[:grant_type] == 'authorization_code'
      authorization_code_token
    end
  end

  private def client_credentials_token
    consumer = Consumer.find_by(client_id_key: params[:client_id], client_secret: params[:client_secret])
    token = consumer.tokens.create
    token.set_as_client_credentials
    render(json: token.client_credentials_token_json)
  end

  private def authorization_code_token
    consumer = Consumer.includes(:redirect_uris).find_by(client_id_key: params[:client_id], client_secret: params[:client_secret], redirect_uris: { uri: params[:redirect_uri] })
    token = consumer.tokens.find_by(grant: 'authorization_code', code: params[:code])
    token.set_tokens_for_authorization_code
    render(json: authorization_code_token_json)
  end
end
