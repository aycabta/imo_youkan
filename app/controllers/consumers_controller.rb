class ConsumersController < ApplicationController
  def create
    @sp = ServiceProvider.find(params[:service_provider_id])
    @sp.consumers.create(name: params[:name])
    redirect_to(service_provider_path(@sp))
  end
end
