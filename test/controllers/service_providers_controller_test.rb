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
    sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    assert_response(:found)
    assert_redirected_to(service_provider_path(assigns(:sp).id))
  end

  test 'should show ServiceProvider' do
    ldap_user = sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    user = User.find_by(uid: ldap_user.uid)
    sp = ServiceProvider.find(assigns(:sp).id)
    get(service_provider_path(sp.id))
    assert_response(:success)
    assert_includes(sp.owners, user)
  end

  test 'should add scope to ServiceProvider' do
    ldap_user = sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    user = User.find_by(uid: ldap_user.uid)
    sp = ServiceProvider.find(assigns(:sp).id)
    params = {
      type: 'add_scope',
      name: 'profile',
      description: 'user description'
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    assert_equal(sp.scopes.size, 1)
    assert_equal(sp.scopes[0].name, 'profile')
  end

  test 'should add some scopes to ServiceProvider' do
    ldap_user = sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    user = User.find_by(uid: ldap_user.uid)
    sp = ServiceProvider.find(assigns(:sp).id)
    params = {
      type: 'add_scope',
      name: 'profile',
      description: 'user description'
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    params = {
      type: 'add_scope',
      name: 'basic',
      description: 'user basic information'
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    assert_equal(sp.scopes.size, 2)
    assert_equal(sp.scopes.map(&:name).sort, %w{basic profile})
  end
end
