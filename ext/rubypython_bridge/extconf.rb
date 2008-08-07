require 'mkmf'
require 'open3'

if (Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f < 2.4)
  puts "I'm sorry you need at least Python 2.4 to use rubypython"
  exit -1
end
dir_config("rubypython_bridge")

unless find_library("python2.5",nil)||find("python2.4",nil)
  puts "Could not find python libraries"
  exit -1
end

unless have_header("Python.h")||have_header("python2.5/Python.h")||have_header("python2.4/Python.h")
  puts "Could not find Python header files"
  exit -1
end

create_makefile("rubypython_bridge")
