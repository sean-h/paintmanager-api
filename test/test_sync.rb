require_relative './sinatra_test'

# Test the sync routes.
class TestSync < SinatraTest

  # Tests that a get request returns all data types
  def test_get_sync
    get 'sync.json'
    data = JSON.parse last_response.body
    assert_equal(true, data.has_key?('brand'))
    assert_equal(true, data.has_key?('paint_range'))
    assert_equal(true, data.has_key?('paint'))
    assert_equal(true, data.has_key?('status_key'))
  end

  def test_post_sync
    paint_data = [ {id: 1, status: 1} ]
    post_data = { paint: paint_data }
    post 'sync.json', post_data
    get 'paints/1.json'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['status'])
  end

end
