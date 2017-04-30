require 'test_helper'

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  test 'should get root without session' do
    get(root_path)
    assert_response(:success)
    assert_nil(assigns(:sps))
    assert_nil(assigns(:new_sp))
  end

  test 'should get root with session' do
    sign_in_as(:great_user)
    get(root_path)
    assert_response(:success)
    assert_not_nil(assigns(:sps))
    assert_not_nil(assigns(:new_sp))
  end

  test 'should redirect from show to index without session' do
    get(service_provider_path(1))
    assert_redirected_to(root_path)
  end

  test 'should not show with unknown ID' do
    sign_in_as(:great_user)
    get(service_provider_path(999))
    assert_response(:not_found)
  end

  test 'should show' do
    sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    get(service_provider_path(assigns(:sp).id))
    assert_response(:success)
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

  test 'should not add scope to ServiceProvider as duplicated name' do
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
    params = {
      type: 'add_scope',
      name: 'profile',
      description: 'user description 2nd'
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    assert_equal(sp.scopes.size, 1)
    assert_equal(flash[:scope_alert].size, 1)
  end

  test 'should add user to ServiceProvider' do
    ldap_user = sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    user = User.find_or_create_by_auth(Fabricate(:little_user))
    sp = ServiceProvider.find(assigns(:sp).id)
    params = {
      type: 'add_user',
      uid: 'little_user',
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    assert_equal(sp.users.size, 2)
    assert_equal(sp.owners.size, 1)
  end

  test 'should not add user to ServiceProvider' do
    ldap_user = sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    sp = ServiceProvider.find(assigns(:sp).id)
    params = {
      type: 'add_user',
      uid: 'unknown_user',
    }
    put(service_provider_path(sp.id), params: params)
    assert_response(:found)
    assert_equal(sp.users.size, 1)
    assert_equal(flash[:user_alert], ['unknown user: unknown_user'])
  end
end
