require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypyapi"
require "rubypyapi.so"

class TestRubypyapiExtn < Test::Unit::TestCase
  def test_truth
    assert true
  end
end