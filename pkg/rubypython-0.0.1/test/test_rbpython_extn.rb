require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rbpython"
require "rbpython.so"

class TestRbpythonExtn < Test::Unit::TestCase
  def test_truth
    assert true
  end
end