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
end
