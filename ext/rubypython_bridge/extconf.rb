require 'mkmf'
require 'open3'

if (Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f < 2.4)
  puts "I'm sorry you need at least Python 2.4 to use rubypython"
  exit -1
end

dir_config("rubypython_bridge")
if(!`which python-config`)
  print "Can't configure with python_config"
  exit -1
end

unless find_library("python2.5",nil)||find("python2.4",nil)
  puts "Could not find python libraries"
  exit -1
end

find_header("Python.h",*`python-config --includes`.split.map{|s| s[2..-1]<<"/"})

create_makefile("rubypython_bridge")
