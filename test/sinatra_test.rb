require 'json'
require 'minitest/autorun'
require 'rack/test'
require_relative '../src/routes'

# Parent class for tests.
class SinatraTest < Minitest::Test
  include Rack::Test::Methods

  # Returns the PaintManager app
  def app
    Routes
  end
end
