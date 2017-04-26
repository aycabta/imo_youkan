require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get session on login' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    assert_response(:found)
    assert_not_nil(assigns(:user))
  end

  test 'should fail to get session on login with invalid password' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: '' })
    assert_response(:found)
    assert_nil(assigns(:user))
  end
end
