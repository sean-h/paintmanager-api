require_relative './sinatra_test'

# Tests the User routes
class TestUser < SinatraTest
  def test_create_user
    user_data = { email: 'test@example.com',
                  password: 'password' }
    post 'user.json', user_data
    assert last_response.ok?
  end
end
