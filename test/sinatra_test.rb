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
end
