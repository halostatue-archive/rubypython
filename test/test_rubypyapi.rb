require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubypyapiBasic < Test::Unit::TestCase
  def test_start_stop
    assert(RubyPython::RubyPyApi.start, "Embedded python interpreter failed to start correctly.")
    
    assert(!RubyPython::RubyPyApi.start, "Interpreter attempted to start while running.")
    
    assert(RubyPython::RubyPyApi.stop, "Interpreter failed to halt.")
    
    assert(!RubyPython::RubyPyApi.stop, "Interpreter ran into trouble while halting.")
  end
  
end

class TestRubypyapiPyObject < Test::Unit::TestCase

  def setup
    RubyPython::RubyPyApi.start
  end
  
  def teardown
    RubyPython::RubyPyApi.stop
  end
  
  def test_imports
    urllib2 = RubyPython::RubyPyApi.import("urllib2")
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       urllib2,
                       "Failed to import object.")
  end
  
  def test_wrap_string
    pyString = RubyPython::RubyPyApi::PyObject.new("STRING");
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyString,
                       "Failed to create PyObject wrapper from ruby string.");
  end
  
  def test_rubify_string
    pyString = RubyPython::RubyPyApi::PyObject.new("STRING");
    unwrapped = pyString.rubify();
    assert_equal("STRING",
                 unwrapped,
                 "Failed to correctly unwrap string.");
  end
  
  def test_wrap_int
    pyInt = RubyPython::RubyPyApi::PyObject.new(1);
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyInt,
                       "Failed to create PyObject wrapper from ruby int.");
  end
  
  def test_rubify_int
    pyInt = RubyPython::RubyPyApi::PyObject.new(1);
    unwrapped = pyInt.rubify();
    assert_equal(1,
                 unwrapped,
                 "Failed to correctly unwrap int.");
  end
  
  def test_wrap_float
    pyFloat = RubyPython::RubyPyApi::PyObject.new(1.0);
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyFloat,
                       "Failed to create PyObject wrapper from ruby float.");
  end
  
  def test_rubify_float
    pyFloat = RubyPython::RubyPyApi::PyObject.new(1.0);
    unwrapped = pyFloat.rubify();
    assert_equal(1.0,
                 unwrapped,
                 "Failed to correctly unwrap float.");
  end
  
  def test_wrap_array
    pyArray = RubyPython::RubyPyApi::PyObject.new([1,'a',1.0,"STRING"]);
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyArray,
                       "Failed to create PyObject wrapper from ruby array.");
  end
  
  def test_rubify_array
    pyArray = RubyPython::RubyPyApi::PyObject.new([1,'a',1.0,"STRING"]);
    unwrapped = pyArray.rubify();
    assert_equal([1,'a',1.0,"STRING"],
                 unwrapped,
                 "Failed to correctly unwrap array.");
  end
  
  def test_wrap_hash
    pyHash = RubyPython::RubyPyApi::PyObject.new({1 => 1,:a => 'a', :sym => 1.0,"STRING" => "STRING"});
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyHash,
                       "Failed to create PyObject wrapper from ruby hash.");
  end
  
  def test_rubify_hash
    pyHash = RubyPython::RubyPyApi::PyObject.new({1 => 1,:a => 'a', :sym => 1.0,"STRING" => "STRING"})
    unwrapped = pyHash.rubify();
    assert_equal({1 => 1,"a" => 'a', "sym" => 1.0,"STRING" => "STRING"},
                 unwrapped,
                 "Failed to correctly unwrap hash.");
  end

  def test_rubify_unsupported
    urllib2 = RubyPython::RubyPyApi.import 'urllib2'
    request = urllib2.getAttr('Request')
    assert_raises RubyPython::RubyPyApi::Conversion::UnsupportedConversion do
      request.rubify
    end
  end

  def test_has_attr_affirmative
    pyStringModule = RubyPython::RubyPyApi.import("string");
    assert(pyStringModule.hasAttr("ascii_letters"),
           "Hasattr failed to detect ascii_letters in string module.")
  end

  def test_has_attr_negative
    pyStringModule = RubyPython::RubyPyApi.import("string")
    assert(!pyStringModule.hasAttr("nonExistentThing"),
                 "Hasattr erroneously claimed existence of a non existent thing.")
  end

  def test_get_attr
    pyStringModule = RubyPython::RubyPyApi.import("string")

    pyAsciiLetters = pyStringModule.getAttr("ascii_letters")
    assert_instance_of(RubyPython::RubyPyApi::PyObject,
                       pyAsciiLetters,
                       "Failed to fetch RubyPyObject with getAttr")
    
    assert_equal("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
                 pyAsciiLetters.rubify,
                 "Failed to correctly getAttr ascii_letters from string module.")
  end

  def test_set_attr
    pyStringModule = RubyPython::RubyPyApi.import("string")

    pyNewLetters = RubyPython::RubyPyApi::PyObject.new("RbPy")

    assert_nothing_raised "Exception raised when trying to setAttr" do
      pyStringModule.setAttr("ascii_letters", pyNewLetters)
    end

    assert_equal(pyNewLetters.rubify,
                pyStringModule.getAttr("ascii_letters").rubify,
                "Returned data was not the same as set data in setAttr-getAttr sequence.")
  end

  def test_set_attr_new
    pyStringModule = RubyPython::RubyPyApi.import("string")

    pyNewString = RubyPython::RubyPyApi::PyObject.new("Python")

    assert_nothing_raised "Exception raised when trying to setAttr new attribute" do
    pyStringModule.setAttr("ruby", pyNewString)
      end
    
    assert_equal(pyNewString.rubify,
                pyStringModule.getAttr("ruby").rubify,
                "Returned data was not the same as set data in new setAttr-getAttr sequence.")
  end

  def test_compare_equal
    a = RubyPython::RubyPyApi::PyObject.new(10)
    b = RubyPython::RubyPyApi::PyObject.new(10)

    assert_equal(0,
                 a.cmp(b),
                 "Rubypython faired to determine equality.")
  end

  def test_compare_bidirectional
    less = RubyPython::RubyPyApi::PyObject.new(5)
    lessb = RubyPython::RubyPyApi::PyObject.new(5)
    greater = RubyPython::RubyPyApi::PyObject.new(10)
    

    assert_equal(less.cmp(greater),
                 -greater.cmp(less),
                 "Comparison is not mutual.")

    assert_equal(less.cmp(lessb),
                 lessb.cmp(less),
                 "Comparison is not mutual.")

  end

  def test_compare_less_than
    less = RubyPython::RubyPyApi::PyObject.new(5)
    greater = RubyPython::RubyPyApi::PyObject.new(10)

    assert_equal(-1,
                 less.cmp(greater),
                 "Failed to correctly evaluate less than.")
  end

  def test_compare_greater_than
    less = RubyPython::RubyPyApi::PyObject.new(5)
    greater = RubyPython::RubyPyApi::PyObject.new(10)

    assert_equal(1,
                 greater.cmp(less),
                 "Failed to correctly evaluate greater than.")
    
  end

  def test_make_tuple
    arg = RubyPython::RubyPyApi::PyObject.new("arg")
    argt = RubyPython::RubyPyApi::PyObject.makeTuple(arg)
    assert_equal(["arg"],
                 argt.rubify,
                 "Failed to correctly wrap with a tuple.")
  end

  def test_call_object
    arg = RubyPython::RubyPyApi::PyObject.new(6)
    argt = RubyPython::RubyPyApi::PyObject.makeTuple(arg)

    builtin = RubyPython::RubyPyApi.import("__builtin__")
    string = builtin.getAttr("str")
    rbString = string.callObject(argt)
    
    assert_equal("6",
                 rbString.rubify,
                 "Failed to call python function correctly.")

    
  end

  def test_new_list
    a = RubyPython::RubyPyApi::PyObject.new("a")
    b = RubyPython::RubyPyApi::PyObject.new("b")

    pList = RubyPython::RubyPyApi::PyObject.newList(a,b)

    assert_equal(["a","b"],
                 pList.rubify,
                 "newList function produced unexpected behavior.")
  end
              

end


class TestRubyPyApi_PythonError < Test::Unit::TestCase
  def setup
    RubyPython::RubyPyApi.start
  end

  def teardown
    RubyPython::RubyPyApi.stop
  end

  def test_error_occurred_negative
    assert(!RubyPython::PythonError.error?,
           "PythonError erroneously detected an error.")
  end

  def test_error_occurred_positive
    RubyPython::RubyPyApi.import("wat")
    assert(RubyPython::PythonError.error?,
           "RubyPython failed to detect error on failed import.")
    RubyPython::PythonError.clear
  end

  def test_error_clear
    RubyPython::RubyPyApi.import("wat")
    RubyPython::PythonError.clear
    assert(!RubyPython::PythonError.error?,
           "PythonError.clear failed to clear error.")
  end

  def test_error_clear_no_error
    RubyPython::PythonError.clear
  end

  def test_error_fetch_type
    RubyPython::RubyPyApi.import("wat")

    rbType, rbValue, rbTraceback = RubyPython::PythonError.fetch()
    rbValue.xDecref
    rbTraceback.xDecref
    eType = rbType.getAttr("__name__").rubify
    rbType.xDecref

    assert_equal("ImportError",
                 eType,
                 "PythonError returned incorrect error type.")
    
  end

end


class TestRubyPyApi_PyProxy < Test::Unit::TestCase

  def initialize(name)
    super(name)
  end


  def setup
    RubyPython::RubyPyApi.start
  end


  def teardown
    RubyPython::RubyPyApi.stop
  end


  def test_initialize_pyproxy
    rbString = RubyPython::RubyPyApi::PyObject.new("string")
    rbProxy = RubyPython::RubyPyApi::RubyPyProxy.new(rbString)
  end

  def test_call_method
    a = RubyPython::RubyPyApi::PyObject.new("a")
    b = RubyPython::RubyPyApi::PyObject.new("b")
    aProxy = RubyPython::RubyPyApi::RubyPyProxy.new(a)
    bProxy = RubyPython::RubyPyApi::RubyPyProxy.new(b)
    abProxy = aProxy.__add__(bProxy)

    assert_equal("ab",
                 abProxy.pObject.rubify,
                 "PyProxy failed to handle method call correctly.")
    
  end

  def test_call_nomethod
    rbString = RubyPython::RubyPyApi::PyObject.new("string")
    rbStringProxy = RubyPython::RubyPyApi::RubyPyProxy.new(rbString)

    assert_raise NoMethodError do
      rbStringProxy.wat []
    end
  end

  def test_call_noargs
    builtin = RubyPython::RubyPyApi.import("__builtin__")
    builtinProxy = RubyPython::RubyPyApi::RubyPyProxy.new(builtin)

    rbStrClass = builtinProxy.str
    rbStr = rbStrClass.new

    assert_equal("",
                 rbStr.pObject.rubify,
                 "Failed to call method str with no args.")
  end

  def test_get_object
    pyStringModule = RubyPython::RubyPyApi.import("string")
    pyAsciiLetters = pyStringModule.getAttr("ascii_letters")    
    
    pyStringProxy = RubyPython::RubyPyApi::RubyPyProxy.new(pyStringModule)

    assert_equal(pyAsciiLetters.rubify,
                 pyStringProxy.ascii_letters.pObject.rubify,
                 "Different methods of getting attr return different values.")

  end

  def test_set_object
    stringMod=RubyPython::RubyPyApi.import("string")
    stringModProxy=RubyPython::RubyPyApi::RubyPyProxy.new(stringMod)
    
    stringModProxy.letters="a"
    
    assert_equal("a",
                 stringModProxy.letters.pObject.rubify,
                 "Failed to set attribute of python object via proxy.")

  end

  def test_rubify
    pyStringModule = RubyPython::RubyPyApi.import("string")
    pyStringProxy = RubyPython::RubyPyApi::RubyPyProxy.new(pyStringModule)
    lettersProxy = pyStringProxy.ascii_letters

    assert_equal(lettersProxy.pObject.rubify,
                lettersProxy.rubify,
                "Rubification of RubyPyProxy does not equal that of wrapped object")


  end

  def test_from_ruby_type
    expected = "STRING"
    proxy = RubyPython::RubyPyApi::RubyPyProxy.new expected

    assert_equal(expected,
                proxy.rubify,
                "Error creating RubyPyProxy directly from a ruby string.")

  end

end


class TestRubyPyApi_CustomTestObject < Test::Unit::TestCase
  def setup
    RubyPython::RubyPyApi.start
  end


  def teardown
    RubyPython::RubyPyApi.stop
  end

  def test_load_custom_file
    rbSys=RubyPython::RubyPyApi::RubyPyProxy.new(RubyPython::RubyPyApi.import("sys"))
    rbPath=rbSys.path
    rbPath.append("./test/python_helpers/")
    RubyPython::RubyPyApi.import "objects"
  end

end
