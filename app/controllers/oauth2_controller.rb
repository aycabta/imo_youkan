class OAuth2Controller < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider
  before_action :check_content_type, only: [:unauthorized, :revoke, :introspect], if: -> { request.post? }

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
    consumer = Consumer.find_by(client_id_key: params[:client_id])
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: 'client_id is unknown'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    elsif !consumer.redirect_uris.exists?(uri: params[:redirect_uri])
      json = {
        error: 'invalid_request',
        error_description: 'redirect_uri is unknown'
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    else
      redirect_params = {
        error: 'access_denied',
        error_description: 'Resource owner denied authorization'
      }
      redirect_params[:state] = params[:state] if params[:state]
      return redirect_to("#{params[:redirect_uri]}##{redirect_params.to_param}")
    end
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
    # TODO checks scope and user
    consumer = Consumer.find_by({ client_id_key: params[:client_id], client_secret: params[:client_secret] })
    if consumer.nil?
      json = {
        error: 'invalid_request',
        error_description: "client_id or client_secret is invalid"
      }
      json[:state] = params[:state] if params[:state]
      return render(json: json, status: :bad_request)
    end
    token = consumer.tokens.find_by(access_token: params[:token])
    if token
      if token.expires_in >= Time.now
        json = {
          active: true,
          scope: token.approved_scopes.map(&:name).join(' '),
        }
        if token.redirect_uri
          json[:redirect_uri] = token.redirect_uri.uri
        end
        if token.user
          json[:user] = {
            uid: token.user.uid,
            name: token.user.name,
            email: token.user.email
          }
        end
        json[:state] = params[:state] if params[:state]
        render(json: json)
      else
        json = { active: false }
        json[:state] = params[:state] if params[:state]
        render(json: json)
      end
    else
      json = { active: false }
      json[:state] = params[:state] if params[:state]
      render(json: json)
    end
  end
end
