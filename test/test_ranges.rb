require_relative './sinatra_test'

class TestRanges < SinatraTest
  def test_get_range_by_id
    get 'ranges/1'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['id'])
  end
end
