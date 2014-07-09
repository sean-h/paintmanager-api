require 'json'
require 'minitest/autorun'
require 'rack/test'
require_relative '../src/routes'

class SinatraTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Routes
  end
end
