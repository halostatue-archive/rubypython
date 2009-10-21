require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypyapi"
require "rubypyapi.so"

class TestRubypyapiExtn < Test::Unit::TestCase
  def setup
    RubyPyApi.start
  end
  
  def teardown
    RubyPyApi.stop
  end
  
  def test_wrap_string
    pyString = RubyPyApi::PyObject.new("STRING");
    assert_instance_of(RubyPyApi::PyObject,
                       pyString,
                       "Failed to create PyObject wrapper from ruby string.");
  end
  
  def test_rubify_string
    pyString = RubyPyApi::PyObject.new("STRING");
    unwrapped = pyString.rubify();
    assert_equal("STRING",
                 unwrapped,
                 "Failed to correctly unwrap string.");
  end
end