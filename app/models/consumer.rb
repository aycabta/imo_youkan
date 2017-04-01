require 'securerandom'

class Consumer < ApplicationRecord
  belongs_to :service_provider
  has_many :tokens
  has_many :accessible_scopes, :through => :consumer_scopes

  after_initialize :set_default, if: :new_record?

  private def set_default
    generate_key_and_secret
  end

  private def generate_key_and_secret
    @client_id_key = "#{@id}_#{SecureRandom.urlsafe_base64(16)}"
    @client_secret = SecureRandom.urlsafe_base64(32)
  end
end
