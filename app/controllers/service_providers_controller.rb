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

  def show
    @sp = ServiceProvider.find(params[:id])
  end

  private def service_provider_params
    params.require(:service_provider).permit(:name)
  end
end
