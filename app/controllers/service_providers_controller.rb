class ServiceProvidersController < ApplicationController
  before_action :authorize!, only: [:new, :create, :show]

  def index
    @new_sp = ServiceProvider.new
    @sps = ServiceProvider.includes(:users).where(users: { id: current_user.id }) if current_user
  end

  def create
    @sp = ServiceProvider.new(service_provider_params)
    @sp.users << current_user
    @sp.save
    redirect_to(service_provider_path(@sp))
  end

  def update
    case params[:type]
    when 'add_user'
      @sp = ServiceProvider.find(params[:id])
      user = User.find_by(email: params[:email])
      redirect_to(service_provider_path(@sp)) unless user
      @sp.users << user
      @sp.save
      redirect_to(service_provider_path(@sp))
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
