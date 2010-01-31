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

class TestRubypyapiPyObject < Test::Unit::TestCase
  def setup
    RubyPyApi.start
  end
  
  def teardown
    RubyPyApi.stop
  end
  
  def test_imports
    urllib2 = RubyPyApi.import("urllib2")
    assert_instance_of(RubyPyApi::PyObject,
                       urllib2,
                       "Failed to import object.")
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

  def test_has_attr_affirmative
    pyStringModule = RubyPyApi.import("string");
    assert(pyStringModule.hasAttr("ascii_letters"),
           "Hasattr failed to detect ascii_letters in string module.")
  end

  def test_has_attr_negative
    pyStringModule = RubyPyApi.import("string")
    assert(!pyStringModule.hasAttr("nonExistentThing"),
                 "Hasattr erroneously claimed existence of a non existent thing.")
  end

  def test_get_attr
    pyStringModule = RubyPyApi.import("string")

    pyAsciiLetters = pyStringModule.getAttr("ascii_letters")
    assert_instance_of(RubyPyApi::PyObject,
                       pyAsciiLetters,
                       "Failed to fetch RubyPyObject with getAttr")
    
    assert_equal("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
                 pyAsciiLetters.rubify,
                 "Failed to correctly getAttr ascii_letters from string module.")
  end

  def test_set_attr
    pyStringModule = RubyPyApi.import("string")

    pyNewLetters = RubyPyApi::PyObject.new("RbPy")

    assert_nothing_raised "Exception raised when trying to setAttr" do
      pyStringModule.setAttr("ascii_letters", pyNewLetters)
    end

    assert_equal(pyNewLetters.rubify,
                pyStringModule.getAttr("ascii_letters").rubify,
                "Returned data was not the same as set data in setAttr-getAttr sequence.")
  end

  def test_set_attr_new
    pyStringModule = RubyPyApi.import("string")

    pyNewString = RubyPyApi::PyObject.new("Python")

    assert_nothing_raised "Exception raised when trying to setAttr new attribute" do
    pyStringModule.setAttr("ruby", pyNewString)
      end
    
    assert_equal(pyNewString.rubify,
                pyStringModule.getAttr("ruby").rubify,
                "Returned data was not the same as set data in new setAttr-getAttr sequence.")
  end

  def test_compare_equal
    a = RubyPyApi::PyObject.new(10)
    b = RubyPyApi::PyObject.new(10)

    assert_equal(0,
                 a.cmp(b),
                 "Rubypython faired to determine equality.")
  end

  def test_compare_bidirectional
    less = RubyPyApi::PyObject.new(5)
    lessb = RubyPyApi::PyObject.new(5)
    greater = RubyPyApi::PyObject.new(10)
    

    assert_equal(less.cmp(greater),
                 -greater.cmp(less),
                 "Comparison is not mutual.")

    assert_equal(less.cmp(lessb),
                 lessb.cmp(less),
                 "Comparison is not mutual.")

  end

  def test_compare_less_than
    less = RubyPyApi::PyObject.new(5)
    greater = RubyPyApi::PyObject.new(10)

    assert_equal(-1,
                 less.cmp(greater),
                 "Failed to correctly evaluate less than.")
  end

  def test_compare_greater_than
    less = RubyPyApi::PyObject.new(5)
    greater = RubyPyApi::PyObject.new(10)

    assert_equal(1,
                 greater.cmp(less),
                 "Failed to correctly evaluate greater than.")
    
  end

end


class TestRubyPyApi_PythonError < Test::Unit::TestCase

  def setup
    RubyPyApi.start
  end

  def teardown
    RubyPyApi.stop
  end

  def test_error_occurred_negative
    assert(!PythonError.error?,
           "PythonError erroneously detected an error.")
  end

  def test_error_occurred_positive
    RubyPyApi.import("wat")
    assert(PythonError.error?,
           "RubyPython failed to detect error on failed import.")
    PythonError.clear
  end

  def test_error_clear
    RubyPyApi.import("wat")
    PythonError.clear
    assert(!PythonError.error?,
           "PythonError.clear failed to clear error.")
  end

  def test_error_clear_no_error
    PythonError.clear
  end

  def test_error_fetch_type
    rbType = RubyPyApi::PyObject.new nil
    rbValue = RubyPyApi::PyObject.new nil
    rbTraceback = RubyPyApi::PyObject.new nil

    RubyPyApi.import("wat")


    PythonError.fetch(rbType, rbValue, rbTraceback)
    rbValue.xDecref
    rbTraceback.xDecref
    eType = rbType.getAttr("__name__").rubify
    rbType.xDecref

    assert_equal("ImportError",
                 eType,
                 "PythonError returned incorrect error type.")
    
  end

end
