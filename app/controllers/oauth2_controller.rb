class OAuth2Controller < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_service_provider

  private def get_service_provider
    @sp = ServiceProvider.find(params[:service_provider_id])
  end

  def token
    if params[:grant_type] == 'client_credentials'
      consumer = Consumer.where(client_id: params[:client_id], client_secret: params[:client_secret])
      token = consumer.tokens.create
      token.set_as_client_credentials
      render :json => {
        expires_in: 3600,
        status: 'success',
        access_token: token.access_token,
        token_type: token.token_type
      }
    end
  end
end
