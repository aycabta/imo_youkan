require 'securerandom'

class Consumer < ApplicationRecord
  belongs_to :service_provider
  has_many :tokens
  has_many :accessible_scopes, :through => :consumer_scopes
  belongs_to :owner, foreign_key: 'user_id', :class_name => 'User'

  after_commit :generate_client_key_and_secret, unless: :client_id_key?

  private def generate_client_key_and_secret
    self.client_id_key = "#{self.id}_#{SecureRandom.urlsafe_base64(16)}"
    self.client_secret = SecureRandom.urlsafe_base64(32)
    self.save
  end
end
