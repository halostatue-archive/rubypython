require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubypython < Test::Unit::TestCase
  

  def setup
    RubyPython.start
  end

  def teardown
    RubyPython.stop
  end

  def test_two_imports
    assert_nothing_raised("Error raised on imports") do
      RubyPython.import "cPickle"
      RubyPython.import "urllib"
    end
  end

  def test_propogate_python_error
    assert_raise(PythonError,"rubypython failed to propogate python error.") do
      RubyPython.import "slasdfj"
    end
    
  end


  def test_instance_method_delegation
    wave=RubyPython.import "wave"
    w=wave.open("test/test.wav","rb")
    assert_equal(9600,
                 w.getframerate.rubify,
                 "Wrapped wave library incorrectly passing framerate.")
    w.close
    
  end

  def test_pymain_delegation
    pyFloat = PyMain.float(42)
    assert_equal(42.to_f,
		 pyFloat.pObject.rubify,
		 "Integer conversion problems in Python.")
    
  end

  def test_block_syntax

    returned = PyMain.float(22) do |f|
      f.rubify*2
    end
    assert_equal(44.0,
                 returned,
                 "Wrapped Python object failed to correctly utilize block syntax.")
  end
    
  def test_setter_ary
    sys=RubyPython.import 'sys'
      
    sys.path=[".",".."]
      
    assert_equal([".",".."],
                 sys.path.rubify,
                 "Ruby failed to modify Python object as expected.")
    
  end
  
  def test_setter_instance
    urllib2=RubyPython.import "urllib2"
    req=urllib2.Request("google.com")
    req.headers={:a=>"2","k"=>4}
    assert_equal({"a"=>"2","k"=>4},
                 req.headers.rubify,
                 "Python dictionary not set as expected.")
  end
  
  def test_set_twice
    sys = RubyPython.import 'sys'
    
    sys.path = ['.']
    
    sys.path = ['..']
    
    assert_equal(['..'],
                 sys.path.rubify,
                 "Ruby failed to modify Python object as expected.")
    
  end
end


class TestWithCustomObject < Test::Unit::TestCase
  def setup
    RubyPython.start
    sys = RubyPython.import 'sys'
    sys.path = ['./test/python_helpers']
    @objects = RubyPython.import 'objects'
  end
  
  def teardown
    RubyPython.stop
  end

  def test_identity_function
    ruby_objects = [0, 1.0, 'STRING', [1, 2, 'LIST'], {'dict' => 'element'}]
    ruby_objects.each do |obj|
      assert_equal(obj,
                  @objects.identity(obj).rubify,
                  "Indentity function is python is identity in ruby.")

    end
  end

  def test_create_new_class_object
    mockObject = @objects.RubyPythonMockObject.new
    assert_instance_of(mockObject,
                   RubyPyApi::RubyPyProxy,
                   "Could not get new class instance from python.")
  end

  def test_string_access
    assert_equal("STRING",
           @objects.RubyPythonMockObject.STRING.rubify,
           "String class members not being converted correctly.")
    rbString = @objects.RubyPythonMockObject.STRING
  end
  
  def test_string_ary_access
    assert_equal(["STRING1", "STRING2"],
                 @objects.RubyPythonMockObject.STRING_LIST.rubify,
                 "List of strings class member not being converted correctly.")
    rbStringList = @objects.RubyPythonMockObject.STRING_LIST
  end
  
  def test_string_ary_modify
    rbStringList = @objects.RubyPythonMockObject.STRING_LIST
    rbStringList.append "NEW_STRING"
    @objects.RubyPythonMockObject.STRING_LIST = rbStringList
    assert_equal("NEW_STRING",
                @objects.RubyPythonMockObject.STRING_LIST.rubify()[2],
                "Failed to add object to list.")
  end

  def test_square_elements
    rbList = [1, 2, 3, 4, 5]
    mockObjectInstance = @objects.RubyPythonMockObject.new
    assert_equal(rbList.map {|x| x**2},
                mockObjectInstance.square_elements(rbList).rubify,
                "List operations not equivalent between ruby and python")
  end

  def test_sum_elements
    rbList = [1, 2, 3, 4, 5]
    mockObjectInstance = @objects.RubyPythonMockObject.new
    assert_equal(rbList.inject(0) {|tot, x| tot += x},
                mockObjectInstance.sum_elements(rbList).rubify,
                "List operations not equivalent between ruby and python")
  end
end

class TestRubyPython_DynamicTypes < Test::Unit::TestCase

  def setup
    RubyPython.start
  end

  def teardown
    RubyPython.stop
  end

  def test_module_wraps_as_module
    urllib2 = RubyPython.import('urllib2')
    assert_instance_of(RubyPyApi::RubyPyModule,
                       urllib2,
                       "Wrapped Python class not of correct type.")

  end

  def test_class_wraps_as_class
    urllib2 = RubyPython.import('urllib2')
    assert_instance_of(RubyPyApi::RubyPyClass,
                       urllib2.Request,
                       "Wrapped Python class not of correct type.")

  end

end
