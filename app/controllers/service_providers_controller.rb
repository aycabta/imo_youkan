class ServiceProvidersController < ApplicationController
  before_action :authorize!, only: [:new, :create, :show]

  def index
    @new_sp = ServiceProvider.new
    @sps = ServiceProvider.all
  end

  def new
    @sp = ServiceProvider.new
  end

  def create
    @sp = ServiceProvider.new(service_provider_params)
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
