class ServiceProviderUser < ApplicationRecord
  belongs_to :service_provider
  belongs_to :user
end

