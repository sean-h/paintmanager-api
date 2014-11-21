require_relative './sinatra_test'

# Test the sync routes.
class TestSync < SinatraTest
  # Tests that a get request returns all data types
  def test_get_sync
    get 'sync.json'
    data = JSON.parse last_response.body
    assert_equal(true, data.key?('brand'))
    assert_equal(true, data.key?('paint_range'))
    assert_equal(true, data.key?('paint'))
    assert_equal(true, data.key?('status_key'))
  end

  # Tests that you can set the status of a paint
  def test_post_sync
    paint_data = [{ id: 1, status: 1 }]
    post_data = { paint: paint_data }
    post 'sync.json', post_data
    get 'paint_statuses/1.json'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['status'].to_i)
  end
end
