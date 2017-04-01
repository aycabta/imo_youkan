class OAuth2Controller < ApplicationController
  before_action :get_service_provider

  def get_service_provider
    @sp = ServiceProvider.find(params[:service_provider_id])
  end

  def token
    render :json => {
      expires_in: 3600
    }
  end
end
