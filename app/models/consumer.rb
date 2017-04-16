require 'securerandom'

class Consumer < ApplicationRecord
  belongs_to :service_provider
  has_many :tokens
  has_many :redirect_uris, class_name: 'RedirectURI'
  belongs_to :owner, foreign_key: 'user_id', class_name: 'User'

  after_commit :generate_client_key_and_secret, unless: :client_id_key?

  validates :name, presence: true, uniqueness: true
  validates :client_id_key, uniqueness: true
  validates :client_secret, uniqueness: true
  validates :user_id, presence: true

  private def generate_client_key_and_secret
    self.client_id_key = "#{self.id}_#{SecureRandom.urlsafe_base64(16)}"
    self.client_secret = SecureRandom.urlsafe_base64(32)
    self.save!
  end

  def token(user, grant)
    self.tokens.find_by(grant: grant, user: user)
  end

  def client_credentials_path
    "/#{self.service_provider.id}/oauth2/token?grant_type=client_credentials&client_id=#{self.client_id_key}&client_secret=#{self.client_secret}"
  end

  def implicit_path(scopes: nil, redirect_uri: nil, state: nil)
    "/#{self.service_provider.id}/oauth2/authorize?response_type=token&client_id=#{self.client_id_key}&redirect_uri=#{redirect_uri_string(redirect_uri)}&scope=#{build_scope_string(scopes)}&state=#{state}"
  end

  def authorization_code_path(scopes: nil, redirect_uri: nil, state: nil)
    "/#{self.service_provider.id}/oauth2/authorize?response_type=code&client_id=#{self.client_id_key}&redirect_uri=#{redirect_uri_string(redirect_uri)}&scope=#{build_scope_string(scopes)}&state=#{state}"
  end

  def token_by_authorization_code_path(token)
    "/#{self.service_provider.id}/oauth2/token?grant_type=authorization_code&client_id=#{self.client_id_key}&client_secret=#{self.client_secret}&redirect_uri=#{token.redirect_uri.uri}&code=#{token.code}"
  end

  private def build_scope_string(scopes)
    if scopes
      scopes.map { |s|
        case s
        when Scope
          s.name
        when String
          s
        end
      }.join(' ')
    else
      self.service_provider.scopes.map(&:name).join(' ')
    end
  end

  private def redirect_uri_string(r)
    case r
    when RedirectURI
      r.uri
    when String
      r
    end
  end
end
