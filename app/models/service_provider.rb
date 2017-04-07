class ServiceProvider < ApplicationRecord
  has_many :consumers
  has_many :scopes
  has_many :service_provider_users
  has_many :users, :through => :service_provider_users
  has_many :owners, -> { where(service_provider_users: {is_owner: true}) }, :through => :service_provider_users, :source => :user

  def owner?(user)
    !!ServiceProvider.includes(:service_provider_users).find_by(id: self.id, service_provider_users: { is_owner: true, user: user })
  end

  def add_user(user)
    sp_user = ServiceProviderUser.new
    sp_user.service_provider = self
    sp_user.user = user
    sp_user.is_owner = false
    sp_user.save
  end

  def add_user_as_owner(user)
    sp_user = ServiceProviderUser.new
    sp_user.service_provider = self
    sp_user.user = user
    sp_user.is_owner = true
    sp_user.save
  end
end
