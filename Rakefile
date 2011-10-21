# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :doofus
Hoe.plugin :gemspec
Hoe.plugin :rubyforge
Hoe.plugin :git
Hoe.plugin :hg

Hoe.spec 'rubypython' do |spec|
  spec.rubyforge_name = spec.name

  developer('Steeve Morin', 'swiuzzz+rubypython@gmail.com')
  developer('Austin Ziegler', 'austin@rubyforge.org')
  developer('Zach Raines', 'raineszm+rubypython@gmail.com')

  spec.remote_rdoc_dir = 'rdoc'
  spec.rsync_args << ' --exclude=statsvn/'

  spec.history_file = 'History.rdoc'
  spec.readme_file = 'README.rdoc'
  spec.extra_rdoc_files = FileList["*.rdoc"].to_a

  spec.extra_deps << ['ffi', '~> 1.0.7']
  spec.extra_deps << ['blankslate', '>= 2.1.2.3']

  spec.extra_dev_deps << ['rspec', '~> 2.0']
  spec.extra_dev_deps << ['tilt', '~> 1.0']

  spec.spec_extras[:requirements]  = [ "Python, ~> 2.4" ]
end

namespace :website do
  desc "Build the website files."
  task :build => [ "website/index.html" ]

  deps = FileList["website/**/*"].exclude { |f| File.directory? f }
  deps.include(*%w(Rakefile))
  deps.include(*FileList["*.rdoc"].to_a)
  deps.exclude(*%w(website/index.html website/images/*))

  file "website/index.html" => deps do |t|
    require 'tilt'
    require 'rubypython'

    puts "Generating #{t.name}…"

    # Let's modify the rdoc for presenation purposes.
    body_rdoc = File.read("README.rdoc")

    contrib = File.read("Contributors.rdoc")
    body_rdoc.gsub!(/^:include: Contributors.rdoc/, contrib)

    license = File.read("License.rdoc")
    body_rdoc.sub!(/^:include: License.rdoc/, license)
    toc_elements = body_rdoc.scan(/^(=+) (.*)$/)
    toc_elements.map! { |e| [ e[0].count('='), e[1] ] }
    body_rdoc.gsub!(/^(=.*)/) { "#{$1.downcase}" }
    body = Tilt::RDocTemplate.new(nil) { body_rdoc }.render

    title = nil
    body.gsub!(%r{<h1>(.*)</h1>}) { title = $1; "" }

    toc_elements = toc_elements.select { |e| e[0].between?(2, 3) }

    last_level = 0
    toc = ""

    toc_elements.each do |element|
      level, text = *element
      ltext = text.downcase
      id = text.downcase.gsub(/[^a-z]+/, '-')

      body.gsub!(%r{<h#{level}>#{ltext}</h#{level}>}) {
        %Q(<h#{level} id="#{id}">#{ltext}</h#{level}>)
      }

      if last_level != level
        if level > last_level
          toc << "<ol>"
        else
          toc << "</li></ol></li>"
        end

        last_level = level
      end

      toc << %Q(<li><a href="##{id}">#{text}</a>)
    end
    toc << "</li></ol>"

    template = Tilt.new("website/index.rhtml", :trim => "<>%")
    context = {
      :title => title,
      :toc => toc,
      :body => body,
      :download => "http://rubyforge.org/frs/?group_id=6737",
      :version => RubyPython::VERSION,
      :modified => Time.now
    }
    File.open(t.name, "w") { |f| f.write template.render(self, context) } end
end

task "docs" => "website:build"

# vim: syntax=ruby
