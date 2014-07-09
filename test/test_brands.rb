require_relative './sinatra_test'

class TestBrands < SinatraTest
  def test_get_brand_by_id
    get 'brands/1'
    data = JSON.parse last_response.body
    assert_equal(data[0]['id'], 1)
  end

  def test_get_all_brands
    get 'brands'
    data = JSON.parse last_response.body
    assert(0 != data.length)
  end
end
