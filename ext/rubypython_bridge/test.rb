require "rubypython_bridge"
p RubyPythonBridge.func_with_module("cPickle","loads","(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
RubyPythonBridge.start
CPickle=RubyPythonBridge.import("cPickle")
p CPickle
p CPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
p dumped_array=CPickle.dumps([1,2,3,4])
p CPickle.loads(dumped_array)
begin
  p CPickle.splack
rescue
  p $!
end
p CPickle.PicklingError
# p CPickle.instance_variable_get("@pdict")
# CPickle.free_pobj
ObjectSpace.each_object(RubyPythonBridge::RubyPyModule) do |o|
  o.free_pobj
end
p RubyPythonBridge.stop

RubyPythonBridge.start
RubyPythonBridge.import "urllib"
RubyPythonBridge.import "cPickle"
RubyPythonBridge.stop
