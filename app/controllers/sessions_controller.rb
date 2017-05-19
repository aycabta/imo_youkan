class SessionsController < ApplicationController
  def create
    ldap_user = LdapUser.first(params['username'])
    # TODO show Flash message
    if !ldap_user.nil? && ActiveLdap::UserPassword.valid?(params['password'], ldap_user.userPassword)
      @user = User.find_or_create_by_auth(ldap_user)
      session[:user_id] = @user.id
      flash[:login_alert] = 'logged in'
      if session[:continued_url]
        url = session[:continued_url]
        session.delete(:continued_url)
        redirect_to(url)
      else
        redirect_to(root_path)
      end
    else
      flash[:login_alert] = 'username or password is wrong'
      redirect_to(root_path)
    end
  end

  def destroy
    session.clear
    redirect_to(root_path)
  end
end
