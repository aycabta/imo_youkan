class ConsumersController < ApplicationController
  before_action :authorize!, only: [:create]

  def create
    @sp = ServiceProvider.includes(:users).find_by(id: params[:service_provider_id], users: { id: current_user.id })
    @sp.consumers.create(name: params[:name], owner: current_user)
    redirect_to(service_provider_path(@sp))
  end
end
