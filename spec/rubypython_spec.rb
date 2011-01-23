require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython do

  before do
    RubyPython.start
  end
  
  after do
    RubyPython.start
  end

  describe "#import" do
    it "should handle multiple imports" do
      lambda do
        RubyPython.import 'cPickle'
        RubyPython.import 'urllib'
      end.should_not raise_exception
    end

    it "should propagate Python errors" do
      lambda do
        RubyPython.import 'nonExistentModule'
      end.should raise_exception(RubyPython::PythonError)
    end

    it "should return a RubyPyModule" do
      RubyPython.import('urllib2').should be_a(RubyPython::RubyPyModule)
    end
  end

end

describe RubyPython, "#session" do

  it "should start interpreter" do
    RubyPython.session do
      cPickle = RubyPython.import "cPickle"
      cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.").rubify.should == {"a"=>"n", [1, "2"]=>4}
    end
  end

  it "should stop the interpreter" do
    RubyPython.session do
      cPickle = RubyPython.import "cPickle"
    end

    RubyPython.stop.should be_false
  end
end

describe RubyPython, "#run" do

  it "should start interpreter" do
    RubyPython.run do
      cPickle = import "cPickle"
      cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.").rubify.should == {"a"=>"n", [1, "2"]=>4}
    end
  end

  it "should stop the interpreter" do
    RubyPython.run do
      cPickle = import "cPickle"
    end

    RubyPython.stop.should be_false
  end

end

describe RubyPython, '#reload_library' do
  it 'leaves RubyPython in a stable state' do
    lambda do 
      RubyPython.instance_eval { reload_library }
      RubyPython.run {}
    end.should_not raise_exception
  end

end

describe RubyPython, '.configure' do
  it 'should allow python executable to be specified', :if =>(not `which python2.6`.empty?) do
    RubyPython.configure :python_exe => 'python2.6'
    RubyPython.run do
      sys = RubyPython.import 'sys'
      sys.version.rubify.to_f.should == 2.6
    end

  end

  after(:all) do
    RubyPython.clear_options
    RubyPython.instance_eval { reload_library }
  end
end
