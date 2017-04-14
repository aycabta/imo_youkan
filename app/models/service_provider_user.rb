class ServiceProviderUser < ApplicationRecord
  belongs_to :service_provider
  belongs_to :user

  validates :service_provider_id, uniqueness: { scope: [:user_id] }
  validates :is_owner, presence: true
end

