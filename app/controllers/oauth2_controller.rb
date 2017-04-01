class OAuth2Controller < ApplicationController
  def token
    render :json => {
      expires_in: 3600
    }
  end
end
