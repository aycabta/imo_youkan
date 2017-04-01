require 'securerandom'

class Token < ApplicationRecord
  belongs_to :consumer
  has_many :approved_scopes, :through => :token_scopes

  def set_as_client_credentials(expires_in_interval: 3600)
    generate_access_token
    self.token_type = 'Bearer'
    self.expires_in = Time.now.since(expires_in_interval.seconds)
  end

  def generate_access_token
    self.access_token = SecureRandom.urlsafe_base64(64)
  end
end
