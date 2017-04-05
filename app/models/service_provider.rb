class ServiceProvider < ApplicationRecord
  has_many :consumers
  has_many :scopes
  has_many :service_provider_users
  has_many :users, :through => :service_provider_users
end
