require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    skip # TODO check ominiauth-github test
    params = {
      provider: 'testprovider',
      uid: '0123abc4567def89',
      info: {
        nickname: 'aycabta',
        email: 'aycabta@gmail.com',
        name: 'Code Ass',
        image: 'http://hogehoge.com/image.png'
      }
    }
    get auth_callback_url(params)
    assert_response :success
  end

end
