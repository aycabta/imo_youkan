require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'an user built by #find_or_create_by_auth is valid' do
    ldap_user = Fabricate(:great_user)
    user = User.find_or_create_by_auth(ldap_user)
    assert_not_nil(user)
    assert_kind_of(String, user.name)
  end
end
