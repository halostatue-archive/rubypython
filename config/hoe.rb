require 'rubypython/version'

AUTHOR = 'Zach Raines'  
EMAIL = "raineszm+rubypython@gmail.com"
DESCRIPTION = "A bridge between ruby and python"
GEM_NAME = 'rubypython' 
RUBYFORGE_PROJECT = 'rubypython' 
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
DOWNLOAD_PATH = "http://rubyforge.org/projects/#{RUBYFORGE_PROJECT}"
EXTRA_DEPENDENCIES = [
  ['ffi', '>=0.6.3'],
  ['blankslate', '>=2.1.2.3']
]    # An array of rubygem dependencies [name, version]


@config_file = "~/.rubyforge/user-config.yml"
@config = nil
RUBYFORGE_USERNAME = "sentient6"
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  RUBYFORGE_USERNAME.replace @config["username"]
end


REV = nil
# UNCOMMENT IF REQUIRED:
# REV = YAML.load(`svn info`)['Revision']
VERS = RubyPython::VERSION::STRING + (REV ? ".#{REV}" : "")

class Hoe
  def extra_deps
    @extra_deps.reject! { |x| Array(x).first == 'hoe' }
    @extra_deps
  end
end

Hoe.plugin :yard

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec(GEM_NAME) do
  self.developer(AUTHOR, EMAIL)
  self.description = DESCRIPTION
  self.summary = DESCRIPTION
  self.url = HOMEPATH
  self.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  self.test_globs = ["test/**/test_*.rb"]
  self.clean_globs |= ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']  #An array of file patterns to delete on clean.
  self.version = VERS
  # == Optional
  self.changes = self.paragraphs_of("History.markdown", 0..1).join("\n\n")
  self.extra_deps = EXTRA_DEPENDENCIES
  self.yard_title = 'RubyPython Documentation'
  self.yard_options=['--markup','markdown']


  self.spec_extras = {
    :requirements => ["Python, ~>2.4"]
  }    # A hash of extra values to set in the gemspec.
  end

PATH    = (RUBYFORGE_PROJECT == GEM_NAME) ? RUBYFORGE_PROJECT : "#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
$hoe.remote_rdoc_dir = File.join(PATH.gsub(/^#{RUBYFORGE_PROJECT}\/?/,''), 'rdoc')
$hoe.rsync_args = '-av --delete --ignore-errors'
$hoe.spec.post_install_message = File.open(File.dirname(__FILE__) + "/../PostInstall.txt").read rescue ""
