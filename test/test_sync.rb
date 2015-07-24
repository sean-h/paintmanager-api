require_relative './sinatra_test'

# Test the sync routes.
class TestSync < SinatraTest
  def setup
    user_data = { email: 'user1@example.com',
                  password: 'password' }
    post 'login', user_data
    data = JSON.parse last_response.body
    @auth = data['auth_token']
  end

  # Tests that a get request returns all data types
  def test_get_sync
    get 'sync.json', {}, { 'HTTP_AUTHORIZATION' => @auth }
    data = JSON.parse last_response.body
    assert_equal(true, data.key?('brand'))
    assert_equal(true, data.key?('paint_range'))
    assert_equal(true, data.key?('paint'))
    assert_equal(true, data.key?('status_key'))
  end

  # Tests that you can set the status of a paint
  def test_post_sync
    paint_data = [{ id: 1, status: 2 }]
    post_data = { paint: paint_data }
    post 'sync.json', post_data, { 'HTTP_AUTHORIZATION' => @auth }
    get 'paint_statuses/1.json'
    data = JSON.parse last_response.body
    assert_equal(2, data[0]['status'].to_i)
  end
end
