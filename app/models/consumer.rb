require 'securerandom'

class Consumer < ApplicationRecord
  belongs_to :service_provider
  has_many :tokens
  has_many :redirect_uris, class_name: 'RedirectURI'
  belongs_to :owner, foreign_key: 'user_id', class_name: 'User'

  after_commit :generate_client_key_and_secret, unless: :client_id_key?

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
end
