require 'securerandom'

class Token < ApplicationRecord
  belongs_to :consumer
  has_many :token_scopes
  has_many :approved_scopes, through: :token_scopes, source: :scope
  belongs_to :redirect_uri, class_name: 'RedirectURI'
  belongs_to :user

  def set_as_client_credentials
    self.grant = 'client_credentials'
    generate_access_token
    self.token_type = 'Bearer'
    self.expires_in = Time.now.since(self.consumer.seconds_to_expire.seconds)
    self.save
  end

  def set_as_implicit(scopes)
    self.grant = 'implicit'
    generate_access_token
    self.token_type = 'Bearer'
    self.expires_in = Time.now.since(self.consumer.seconds_to_expire.seconds)
    selected_scopes = self.consumer.service_provider.scopes.select { |s| scopes.include?(s.name) }
    self.approved_scopes = selected_scopes
    self.save
  end

  def set_as_authorization_code(scopes)
    self.grant = 'authorization_code'
    generate_code
    selected_scopes = self.consumer.service_provider.scopes.select { |s| scopes.include?(s.name) }
    self.approved_scopes = selected_scopes
    self.save
  end

  def set_tokens_for_authorization_code
    self.generate_access_token
    self.generate_refresh_token
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

  def redirect_uri_to_implicit_token
    redirect_params = {
      access_token: self.access_token,
      token_type: 'bearer',
      expires_in: 3600,
      scope: 'basic',
      state: self.state
    }
    "#{self.redirect_uri.uri}##{redirect_params.to_param}"
  end

  def redirect_uri_to_authorize_redirect_with_code
    redirect_params = {
      code: self.code,
      state: self.state
    }
    "#{self.redirect_uri.uri}?#{redirect_params.to_param}"
  end

  def client_credentials_token_json
    {
      expires_in: self.consumer.seconds_to_expire,
      status: 'success',
      access_token: self.access_token,
      token_type: self.token_type
    }
  end

  def authorization_code_token_json
    {
      expires_in: self.consumer.seconds_to_expire,
      status: 'success',
      access_token: self.access_token,
      token_type: self.token_type,
      refresh_token: self.refresh_token,
      scope: self.token.approved_scopes.map { |s| s.name }.join(' ')
    }
  end
end
