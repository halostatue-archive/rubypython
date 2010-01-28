require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypyapi"
require "rubypyapi.so"

class TestRubypyapiBasic < Test::Unit::TestCase
  def test_start_stop
    assert(RubyPyApi.start, "Embedded python interpreter failed to start correctly.")
    
    assert(!RubyPyApi.start, "Interpreter attempted to start while running.")
    
    assert(RubyPyApi.stop, "Interpreter failed to halt.")
    
    assert(!RubyPyApi.stop, "Interpreter ran into trouble while halting.")
  end
  
end

class TestRubypyapiExtn < Test::Unit::TestCase
  def setup
    RubyPyApi.start
  end
  
  def teardown
    RubyPyApi.stop
  end
  
  def test_imports
    RubyPyApi.start
    urllib2 = RubyPyApi.import("urllib2")
    assert_instance_of(RubyPyApi::PyObject,
                       urllib2,
                       "Failed to import object.")
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
  
  def test_wrap_int
    pyInt = RubyPyApi::PyObject.new(1);
    assert_instance_of(RubyPyApi::PyObject,
                       pyInt,
                       "Failed to create PyObject wrapper from ruby int.");
  end
  
  def test_rubify_int
    pyInt = RubyPyApi::PyObject.new(1);
    unwrapped = pyInt.rubify();
    assert_equal(1,
                 unwrapped,
                 "Failed to correctly unwrap int.");
  end
  
  def test_wrap_float
    pyFloat = RubyPyApi::PyObject.new(1.0);
    assert_instance_of(RubyPyApi::PyObject,
                       pyFloat,
                       "Failed to create PyObject wrapper from ruby float.");
  end
  
  def test_rubify_float
    pyFloat = RubyPyApi::PyObject.new(1.0);
    unwrapped = pyFloat.rubify();
    assert_equal(1.0,
                 unwrapped,
                 "Failed to correctly unwrap float.");
  end
  
  def test_wrap_array
    pyArray = RubyPyApi::PyObject.new([1,'a',1.0,"STRING"]);
    assert_instance_of(RubyPyApi::PyObject,
                       pyArray,
                       "Failed to create PyObject wrapper from ruby array.");
  end
  
  def test_rubify_array
    pyArray = RubyPyApi::PyObject.new([1,'a',1.0,"STRING"]);
    unwrapped = pyArray.rubify();
    assert_equal([1,'a',1.0,"STRING"],
                 unwrapped,
                 "Failed to correctly unwrap array.");
  end
  
  def test_wrap_hash
    pyHash = RubyPyApi::PyObject.new({1 => 1,:a => 'a', :sym => 1.0,"STRING" => "STRING"});
    assert_instance_of(RubyPyApi::PyObject,
                       pyHash,
                       "Failed to create PyObject wrapper from ruby hash.");
  end
  
  def test_rubify_hash
    pyHash = RubyPyApi::PyObject.new({1 => 1,:a => 'a', :sym => 1.0,"STRING" => "STRING"})
    unwrapped = pyHash.rubify();
    assert_equal({1 => 1,"a" => 'a', "sym" => 1.0,"STRING" => "STRING"},
                 unwrapped,
                 "Failed to correctly unwrap hash.");
  end
end
