class User < ApplicationRecord
  has_one :token

  def self.find_or_create_by_auth(auth)
    user = User.find_or_create_by(provider: auth['provider'], uid: auth['uid'])

    user.nickname = auth['info']['nickname']
    user.email = auth['info']['email']
    user.name = auth['info']['name']
    user.image_url = auth['info']['image']

    user.save
    user
  end
end