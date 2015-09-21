require 'json'
require 'minitest/autorun'
require 'rack/test'
require_relative '../src/paintmanager'

# Parent class for tests.
class SinatraTest < Minitest::Test
  include Rack::Test::Methods

  # Returns the PaintManager app
  def app
    I18n.enforce_available_locales = false
    PaintManager
  end

  def login
    user_data = { email: 'user1@example.com',
                  password: 'password' }
    post 'login', user_data
    data = JSON.parse last_response.body
    data['auth_token']
  end
end
