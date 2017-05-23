class OAuth2::AuthorizeCodeController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider
  before_action :check_content_type, if: -> { request.post? }

  def new
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: 'client_id is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    redirect_uri = consumer.redirect_uris.find_by(uri: params[:redirect_uri])
    if redirect_uri.nil?
      json = {
        error: 'invalid_request',
        error_description: 'redirect_uri is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    splited_scopes = params[:scope].split(' ')
    rejected_scopes = consumer.service_provider.unknown_scopes(splited_scopes)
    unless rejected_scopes.empty?
      redirect_params = {
        error: 'invalid_scope',
        error_description: "Unknown scopes: #{rejected_scopes.join(', ')}"
      }
      return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
    end
    if current_user
      @scopes = consumer.service_provider.scopes.select { |s| splited_scopes.include?(s.name) }
      token = consumer.tokens.find_by(grant: 'authorization_code', user: current_user)
      if token.nil? || token.code.nil?
        render(template: 'oauth2/authorize')
      else
        token.redirect_uri = redirect_uri
        token.state = params[:state]
        redirect_to(token.redirect_uri_to_authorize_redirect_with_code)
      end
    else
      session[:continued_url] = request.url
      render(template: 'oauth2/authorize_login')
    end
  end

  def create
    # TODO add test for checking each params separately and returns error
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: 'client_id is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    redirect_uri = consumer.redirect_uris.find_by(uri: params[:redirect_uri])
    if redirect_uri.nil?
      json = {
        error: 'invalid_request',
        error_description: 'redirect_uri is invalid'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    token = consumer.tokens.find_or_create_by!(grant: 'authorization_code', user: current_user)
    if token.code.nil? # TODO test for generation token and already existance token
      splited_scopes = params[:scope].split(' ')
      scopes = consumer.service_provider.scopes.select { |s| splited_scopes.include?(s.name) }
      token.set_as_authorization_code(scopes, params[:state], params[:redirect_uri])
    end
    redirect_to(token.redirect_uri_to_authorize_redirect_with_code)
  end
end
