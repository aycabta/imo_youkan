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
end
