require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'an user built by #find_or_create_by_auth is valid' do
    user = User.find_or_create_by_auth({
      'provider' => 'testprovider',
      'uid' => '0123abc4567def89',
      'info' => {
        'nickname' => 'aycabta',
        'email' => 'aycabta@gmail.com',
        'name' => 'Code Ass',
        'image' => 'http://hogehoge.com/image.png'
      }
    })
    refute_nil(user)
    assert_kind_of(String, user.name)
  end
end
