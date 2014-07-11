require_relative './sinatra_test'

# Test the Paint routes.
class TestPaints < SinatraTest
  # Tests that paints can be fetched by id.
  def test_get_paint_by_id
    get 'paints/1'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['id'])
  end
end
