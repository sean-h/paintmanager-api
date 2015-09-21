require_relative './sinatra_test'

# Test the Paint routes.
class TestPaints < SinatraTest
  # Tests that paints can be fetched by id.
  def test_get_paint_by_id
    get 'paints/1.json'
    data = JSON.parse last_response.body
    assert_equal(1, data[0]['id'])
  end

  def test_create_paint
    header 'AUTHORIZATION', login
    data = { name: 'Test Paint', color: '#FF00FF', range_id: 1 }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert_equal(data[:name], response['name'])
  end

  def test_create_paint_errors
    header 'AUTHORIZATION', login
    data = { color: '#FF00FF', range_id: 1 }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert(response.key?('error'), 'Response does not contain any errors')
    assert(response['error'].key?('name'), 'Response does not contain missing name error')
  end
end
