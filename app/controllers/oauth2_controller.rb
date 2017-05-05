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
end
