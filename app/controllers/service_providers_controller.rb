class ServiceProvidersController < ApplicationController
  before_action :authorize!, only: [:new, :create, :show]

  def index
    @new_sp = ServiceProvider.new
    @sps = ServiceProvider.includes(:users).where(users: { id: current_user.id }) if current_user
  end

  def create
    @sp = ServiceProvider.create(service_provider_params)
    @sp.add_user_as_owner(current_user)
    redirect_to(service_provider_path(@sp))
  end

  def update
    case params[:type]
    when 'add_user'
      @sp = ServiceProvider.find(params[:id])
      return redirect_to(service_provider_path(@sp)) unless @sp.owner?(current_user)
      user = User.find_by(email: params[:email])
      redirect_to(service_provider_path(@sp)) unless user
      @sp.add_user(user)
      @sp.save
      return redirect_to(service_provider_path(@sp))
    when 'add_scope'
      @sp = ServiceProvider.find(params[:id])
      return redirect_to(service_provider_path(@sp)) unless @sp.owner?(current_user)
      scope = Scope.create(service_provider: @sp, name: params[:name])
      @sp.scopes << scope
      @sp.save
      return redirect_to(service_provider_path(@sp))
    end
  end

  def show
    @sp = ServiceProvider.includes(:users).find_by(id: params[:id], users: { id: current_user.id })
    if @sp.nil?
      render(file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html')
    end
  end

  private def service_provider_params
    params.require(:service_provider).permit(:name)
  end
end
