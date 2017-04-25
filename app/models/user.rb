class User < ApplicationRecord
  has_many :service_provider_users
  has_many :service_providers, through: :service_provider_users
  has_many :consumers

  validates :uid, uniqueness: true, allow_nil: true

  def self.find_or_create_by_auth(ldap_user)
    user = User.find_or_create_by!(uid: ldap_user.uid)
    user.email = ldap_user.mail
    user.name = ldap_user.cn

    user.save!
    user
  end
end
