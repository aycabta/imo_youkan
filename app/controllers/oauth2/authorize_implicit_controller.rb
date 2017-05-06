class OAuth2::AuthorizeImplicitController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider
  before_action :check_content_type, if: -> { request.post? }

  def new
    if params[:client_id].nil? || params[:redirect_uri].nil?
      needed = []
      needed << 'client_id' if params[:client_id].nil?
      needed << 'redirect_uri' if params[:redirect_uri].nil?
      json = {
        error: 'invalid_request',
        error_description: "#{needed.join(' and ')} #{needed.size == 1 ? 'is' : 'are'} required"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    consumer = @sp.consumers.find_by(client_id_key: params[:client_id])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: "client_id (#{params[:client_id]}) is invalid"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    if !consumer.redirect_uris.exists?(uri: params[:redirect_uri])
      json = {
        error: 'invalid_request',
        error_description: "redirect_uri (#{params[:redirect_uri]}) is invalid"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    scopes = params[:scope].split(' ')
    rejected_scopes = consumer.service_provider.unknown_scopes(scopes)
    if rejected_scopes.any?
      redirect_params = {
        error: 'invalid_scope',
        error_description: "Unknown scopes: #{rejected_scopes.join(', ')}"
      }
      redirect_params[:state] = params[:state] if params[:state]
      return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
    end
    if current_user
      token = consumer.tokens.find_or_create_by!(grant: 'implicit', user: current_user)
      token.set_as_implicit(scopes, params[:state], params[:redirect_uri])
      redirect_to(token.redirect_uri_to_implicit_token)
    else
      session[:continued_url] = request.url
      render(template: 'oauth2/authorize_login')
    end
  end
end
