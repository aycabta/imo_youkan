require 'test_helper'

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  test 'should get root without session' do
    get(root_path)
    assert_response(:success)
    assert_nil(assigns(:sps))
    assert_not_nil(assigns(:new_sp))
  end

  test 'should redirect from show to index without session' do
    get(service_provider_path(1))
    assert_redirected_to(root_path)
  end

  test 'should create ServiceProvider' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    assert_response(:found)
    assert_redirected_to(service_provider_path(assigns(:sp).id))
  end

  test 'should show ServiceProvider' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    user = User.find_by(uid: ldap_user.uid)
    sp = ServiceProvider.includes(:users).find_by(service_provider_users: { is_owner: true, user: user })
    get(service_provider_path(sp.id))
    assert_response(:success)
  end
end
