require 'test_helper'

class ConsumersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(:great_user)
    post(service_providers_path, params: { service_provider: { name: 'test service provider' } })
    @sp = ServiceProvider.find(assigns(:sp).id)
  end

  test 'should create Consumer' do
    post(service_provider_consumers_path(@sp.id), params: { name: 'test consumer' })
    assert_response(:found)
    assert_redirected_to(service_provider_path(@sp.id))
  end

  test 'should show Consumer' do
    post(service_provider_consumers_path(@sp.id), params: { name: 'test consumer' })
    get(service_provider_consumer_path(@sp.id, Consumer.find_by(name: 'test consumer').id))
    assert_response(:success)
    assert_not_nil(assigns(:consumer))
  end

  test 'should update Consumer with add_redirect_uri' do
    post(service_provider_consumers_path(@sp.id), params: { name: 'test consumer' })
    consumer = Consumer.find_by(name: 'test consumer')
    assert_equal(0, consumer.redirect_uris.size)
    params = {
      type: 'add_redirect_uri',
      uri: 'http://foo.com'
    }
    put(service_provider_consumer_path(@sp.id, consumer.id), params: params)
    assert_response(:found)
    assert_redirected_to(service_provider_consumer_path(@sp.id, consumer.id))
    consumer = Consumer.find_by(name: 'test consumer')
    assert_equal(1, consumer.redirect_uris.size)
  end
end
