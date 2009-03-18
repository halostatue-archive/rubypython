require 'mkmf'
require 'open3'

begin
  if (Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f < 2.4)
    puts "I'm sorry you need at least Python 2.4 to use rubypython"
    exit -1
  end
rescue
  puts "Could not check python version. Do you have Python 2.4 or higher? (y/n)"
  if(gets.chomp == "n")
    puts "Please install Python 2.4 or higher"
    exit
  end
  puts "Okay."
end
dir_config("rubypython_bridge")
if(!system("which python-config"))
  print "Can't configure with python_config"
  exit -1
end

unless find_library("python2.5",nil)||find("python2.4",nil)
  puts "Could not find python libraries"
  exit -1
end

if RUBY_VERSION=~/1\.9/ then
	puts "Building for Ruby 1.9"
	$CPPFLAGS += " -DRUBY_19"
end

find_header("Python.h",*`python-config --includes`.split.map{|s| s[2..-1]<<"/"})

create_makefile("rubypython_bridge")
