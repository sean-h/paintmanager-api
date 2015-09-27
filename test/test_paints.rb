require_relative './sinatra_test'

# Test the Paint routes.
class TestPaints < SinatraTest
  # Tests that paints can be fetched by id.
  def test_get_paint_by_id
    get 'paints/1.json'
    data = JSON.parse last_response.body
    assert last_response.ok?
    assert_equal(1, data[0]['id'])
  end

  def test_get_missing_paint_by_id
    get 'paints/10000.json'
    assert last_response.ok?
    data = JSON.parse last_response.body
    assert_equal([], data)
  end

  def test_create_paint
    header 'AUTHORIZATION', login
    data = { name: 'Test Paint', color: '#FF00FF', range_id: 1 }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert_equal(data[:name], response['name'])

    paint_id = response['id']
    get "paints/#{paint_id}.json"
    assert last_response.ok?
    new_data = JSON.parse last_response.body
    assert_equal(data[:name], new_data[0]['name'])
    assert_equal(data[:color], new_data[0]['color'])
    assert_equal(data[:range_id], new_data[0]['range_id'])
  end

  def test_create_paint_no_name_error
    header 'AUTHORIZATION', login
    data = { color: '#FF00FF', range_id: 1 }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert(response.key?('error'), 'Response does not contain any errors')
    assert(response['error'].key?('name'), 'Response does not contain missing name error')
  end

  def test_create_paint_no_color_error
    header 'AUTHORIZATION', login
    data = { name: 'Test Paint', range_id: 1 }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert(response.key?('error'), 'Response does not contain any errors')
    assert(response['error'].key?('color'), 'Response does not contain missing color error')
  end

  def test_create_paint_no_range_error
    header 'AUTHORIZATION', login
    data = { name: 'Test Paint', color: '#FF00FF' }
    post '/paints', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert(response.key?('error'), 'Response does not contain any errors')
    assert(response['error'].key?('range_id'), 'Response does not contain missing range_id error')
  end
end
