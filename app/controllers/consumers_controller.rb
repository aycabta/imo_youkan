class ConsumersController < ApplicationController
  before_action :authorize!, only: [:create, :update, :show]

  def create
    @sp = ServiceProvider.includes(:users).find_by(id: params[:service_provider_id], users: { id: current_user.id })
    @sp.consumers.create(name: params[:name], owner: current_user)
    redirect_to(service_provider_path(@sp))
  end

  def update
    @sp = ServiceProvider.includes(:users).find_by(id: params[:service_provider_id], users: { id: current_user.id })
    consumer = Consumer.find(params[:id])
    case params[:type]
    when 'add_redirect_uri'
      consumer.redirect_uris.create(uri: params[:redirect_uri])
      redirect_to(service_provider_path(@sp))
    end
  end

  def show
    @consumer = Consumer.includes(:owner).find_by(id: params[:id], service_provider_id: params[:service_provider_id], users: { id: current_user.id })
  end
end
