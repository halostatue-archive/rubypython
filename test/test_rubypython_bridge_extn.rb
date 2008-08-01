require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypython_bridge"
require "rubypython_bridge.so"

class TestRubypythonBridgeExtn < Test::Unit::TestCase
  def test_truth
    assert true
  end
end