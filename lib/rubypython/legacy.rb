require 'rubypython'

# A quick way to active <em>Legacy Mode</em> for a project. Requiring
# +'rubypython/legacy' automatically activates +RubyPython.legacy_mode+ on
# the project.
#
# This mode may be phased out for RubyPython 1.0.
#
# === Default
#   require 'rubypython'
#
#   RubyPython.session do
#     string = RubyPython.import 'string'
#     ascii_letters = string.ascii_letters
#     puts ascii_letters.isalpha # => True
#     puts ascii_letters.rubify.isalpha # throws NoMethodError
#   end
#
# === Legacy Mode
#   require 'rubypython/legacy'
#
#   RubyPython.session do
#     string = RubyPython.import 'string'
#     ascii_letters = string.ascii_letters
#     puts ascii_letters.isalpha # throws NoMethodError
#   end
module RubyPython::LegacyMode
  # Enables +RubyPython.legacy_mode+.
  def self.setup_legacy
    RubyPython.legacy_mode = true
  end

  # Disables +RubyPython.legacy_mode+.
  def self.teardown_legacy
    RubyPython.legacy_mode = false
  end
end

RubyPython::LegacyMode.setup_legacy
