require_relative './sinatra_test'

# Tests the User routes
class TestUser < SinatraTest

  def initialize(name)
    super(name)
    @email_blank = "Email can't be blank"
    @password_blank = "Password can't be blank"
  end

  def test_create_user
    user_data = { email: 'test@example.com',
                  password: 'password' }
    post 'user.json', user_data
    assert last_response.ok?
  end

  def test_create_user_no_data
    user_data = {}
    post 'user.json', user_data
    data = JSON.parse last_response.body
    assert(data.key?('errors'), 'Response does not contain an "errors" key')
    assert(data['errors'].include?(@email_blank),
           "Missing error: #{@email_blank}")
    assert(data['errors'].include?(@password_blank),
           "Missing error: #{@password_blank}")
  end

  # Tests that duplicate accounts with the same email address cannot be created
  def test_duplicate_email_error
    user_data = { email: 'user1@example.com',
                  password: 'password' }
    post 'user.json', user_data
    assert last_response.ok?
    data = JSON.parse last_response.body
    assert(data.key?('errors'), 'Response does not contain an "errors" key')
  end
end
