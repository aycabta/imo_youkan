require 'securerandom'

class Token < ApplicationRecord
  belongs_to :consumer
  has_many :token_scopes
  has_many :approved_scopes, :through => :token_scopes
  belongs_to :user

  def set_as_client_credentials
    generate_access_token
    self.token_type = 'Bearer'
    self.expires_in = Time.now.since(self.consumer.seconds_to_expire.seconds)
    self.save
  end

  def set_as_implicit
    generate_access_token
    self.token_type = 'Bearer'
    self.expires_in = Time.now.since(self.consumer.seconds_to_expire.seconds)
    self.save
  end

  def generate_code
    self.code = SecureRandom.urlsafe_base64(64)
  end

  def generate_access_token
    self.access_token = SecureRandom.urlsafe_base64(64)
  end

  def generate_refresh_token
    self.refresh_token = SecureRandom.urlsafe_base64(64)
  end
end
