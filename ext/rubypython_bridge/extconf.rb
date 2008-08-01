require 'mkmf'

dir_config("rubypython_bridge")
find_library("python2.5",nil)
find_header("python2.5/Python.h")

create_makefile("rubypython_bridge")
