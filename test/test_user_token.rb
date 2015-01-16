require_relative './sinatra_test'
require_relative '../src/user_token'

# Test the UserToken model
class TestUserToken < SinatraTest
  def test_create_token
    token = UserToken.create(user_id: 1)
    assert(token.token.nil? == false, 'Generated UserToken is nil')
    assert(token.expires.nil? == false, 'Generated UserToken.expires is nil')
    assert(token.expires > Time.now,
           'Generated UserToken.expires is not in the future')
  end
end
