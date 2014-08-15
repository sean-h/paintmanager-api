require_relative './sinatra_test'

# Tests the PaintRange routes.
class TestRanges < SinatraTest
  # Tests that PaintRanges can be fetched by id.
  def test_get_range_by_id
    get 'ranges/1.json'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['id'])
  end
end
