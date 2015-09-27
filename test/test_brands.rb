require_relative './sinatra_test'

# Tests the Brand routes.
class TestBrands < SinatraTest
  # Tests that a brand can be fetched by it's id.
  def test_get_brand_by_id
    get 'brands/1.json'
    data = JSON.parse last_response.body
    assert_equal(data[0]['id'], 1)
  end

  # Tests that all brands can be fetched.
  def test_get_all_brands
    get 'brands.json'
    data = JSON.parse last_response.body
    assert(0 != data.length)
  end

  def test_create_brand
    header 'AUTHORIZATION', login
    data = { name: 'Test Brand' }
    post '/brands', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert_equal(data[:name], response['name'])

    paint_id = response['id']
    get "brands/#{paint_id}.json"
    assert last_response.ok?
    new_data = JSON.parse last_response.body
    assert_equal(data[:name], new_data[0]['name'])
  end

  def test_create_brand_no_name_error
    header 'AUTHORIZATION', login
    data = { }
    post '/brands', data
    assert last_response.ok?
    response = JSON.parse last_response.body
    assert(response.key?('error'), 'Response does not contain any errors')
    assert(response['error'].key?('name'), 'Response does not contain missing name error')
  end
end
