require 'test_helper'

class OAuth2ControllerTest < ActionDispatch::IntegrationTest
  test 'should fail /oauth2/authorize without response_type' do
    get(oauth2_authorize_path(ServiceProvider.first.id))
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('response_type is required', json['error_description'])
  end

  test 'should fail /oauth2/authorize with unknown response_type' do
    params = { response_type: 'unknown_type' }
    get(oauth2_authorize_path(ServiceProvider.first.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('unsupported_response_type', json['error'])
    assert_equal('unknown_type is unknown', json['error_description'])
  end

  test 'should deny access to /oauth2/unauthorize' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).fragment).to_h
    assert_equal('access_denied', queries['error'])
    assert_equal('Resource owner denied authorization', queries['error_description'])
    assert_equal('abcABC', queries['state'])
  end

  test 'should fail to /oauth2/unauthorize with unknown client_id' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    params = {
      client_id: consumer.client_id_key + 'unknown',
      redirect_uri: consumer.redirect_uris.first.uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal("client_id (#{consumer.client_id_key + 'unknown'}) is unknown", json['error_description'])
    assert_equal('abcABC', json['state'])
  end

  test 'should fail to /oauth2/unauthorize with unknown redirect_uri' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri + 'unknown'
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal("redirect_uri (#{redirect_uri}) is unknown", json['error_description'])
    assert_equal('abcABC', json['state'])
  end
end
