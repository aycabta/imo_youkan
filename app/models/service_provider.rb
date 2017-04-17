class ServiceProvider < ApplicationRecord
  has_many :consumers
  has_many :scopes
  has_many :service_provider_users
  has_many :users, through: :service_provider_users
  has_many :owners, -> { where(service_provider_users: {is_owner: true}) }, through: :service_provider_users, source: :user

  validates :name, presence: true, uniqueness: true

  def owner?(user)
    ServiceProviderUser.exists?(service_provider: self, user: user, is_owner: true)
  end

  def user_belongs?(user)
    ServiceProviderUser.exists?(service_provider: self, user: user)
  end

  def consumers_by_user(user)
    Consumer.includes(:service_provider).where(service_provider: self, owner: user)
  end

  def add_user(user)
    unless user_belongs?(user)
      self.service_provider_users.create!(user: user, is_owner: false)
    end
  end

  def add_user_as_owner(user)
    unless user_belongs?(user)
      self.service_provider_users.create!(user: user, is_owner: true)
    end
  end

  def unknown_scopes(given_scopes)
    given_scopes.select { |given_scope| !self.scopes.find { |s| s.name == given_scope } }
  end
end
