class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def authorize!
    redirect_to(root_path) unless current_user
  end
end
