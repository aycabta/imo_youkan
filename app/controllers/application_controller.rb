class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def authorize!
    redirect_to(root_path) unless current_user
  end

  helper_method def check_content_type
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

  helper_method def get_service_provider
    @sp = ServiceProvider.find(params[:service_provider_id])
  end
end
