require "rubypython"
p RubyPython.func_with_module("cPickle","loads","(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
RubyPython.start
CPickle=RubyPython.import("cPickle")
p CPickle
p CPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
p dumped_array=CPickle.dumps([1,2,3,4])
p CPickle.loads(dumped_array)
begin
  p CPickle.splack
rescue
  p $!
end
RubyPython.stop