class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_by_auth(request.env['omniauth.auth'])
    if @user
      session[:user_id] = @user.id
      if session[:continued_url]
        url = session[:continued_url]
        session.delete(:continued_url)
        redirect_to(url)
      else
        redirect_to(root_path)
      end
    else
      redirect_to(root_path)
    end
  end

  def destroy
    session.clear
    redirect_to(root_path)
  end
end
