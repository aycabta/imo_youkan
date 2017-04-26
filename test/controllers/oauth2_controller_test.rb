require 'test_helper'

class OAuth2ControllerTest < ActionDispatch::IntegrationTest
  test 'should fail /oauth2/token with invalid Content-Type' do
    post(oauth2_token_path(ServiceProvider.first.id), headers: { 'CONTENT_TYPE': 'text/plain' })
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('Request header validation failed.', json['error_description'])
    assert_equal('text/plain is invalid, must be application/x-www-form-urlencoded', json['error_details']['content_type'])
    assert_equal('error', json['status'])
  end

  test 'should fail /oauth2/token without response_type' do
    headers = { CONTENT_TYPE: 'application/x-www-form-urlencoded' }
    get(oauth2_authorize_path(ServiceProvider.first.id), headers: headers)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('response_type is required', json['error_description'])
  end

  test 'should fail /oauth2/token with unknown response_type' do
    headers = { CONTENT_TYPE: 'application/x-www-form-urlencoded' }
    params = { response_type: 'unknown_type' }
    get(oauth2_authorize_path(ServiceProvider.first.id), headers: headers, params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('unknown_type is unknown', json['error_description'])
  end

  test 'should get /oauth2/token for implicit without session' do
    headers = { CONTENT_TYPE: 'application/x-www-form-urlencoded' }
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    consumer.run_callbacks(:commit)
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.join(' ')
    }
    get(oauth2_authorize_path(sp.id), headers: headers, params: params)
    assert_response(:success)
    assert_template(:authorize_login)
  end
end
