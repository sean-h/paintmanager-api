require_relative './sinatra_test'

class TestPaints < SinatraTest
  def test_get_paint_by_id
    get 'paints/1'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['id'])
  end
end
