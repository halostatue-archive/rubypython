require 'rubypython'

# A quick way to activate <em>Legacy Mode</em> for a project. Requiring
# +'rubypython/legacy' automatically activates +RubyPython.legacy_mode+ on
# the project. This mode is deprecated and will be removed.
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
