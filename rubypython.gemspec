# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/lib/rubypython/version')

Gem::Specification.new do |s|
  s.name = 'rubypython'
  s.version = RubyPython::VERSION::STRING

  s.authors = ["Zach Raines"]
  s.cert_chain = ["/Users/rainesz/.gem/gem-public_cert.pem"]
  s.description = 'A bridge between ruby and python'
  s.email = ["raineszm+rubypython@gmail.com"]
  s.extra_rdoc_files = ["License.txt", "Manifest.txt", "PostInstall.txt", "History.markdown"]
  s.files = File.read("Manifest.txt").split(/\r?\n\r?/) 
  s.homepage = 'http://bitbucket.org/raineszm/rubypython/'
  s.has_rdoc = 'yard'
  s.post_install_message = File.read("PostInstall.txt")
  
  s.rdoc_options = ["--markup", "markdown", "--title", "RubyPython Documentation", "--quiet"]
  s.require_paths = ["lib"]
  s.requirements = ["Python, ~>2.4"]
  s.rubyforge_project = 'rubypython'
  s.rubygems_version = '1.3.7'
  s.signing_key = '/Users/rainesz/.gem/gem-private_key.pem'
  s.summary = 'A bridge between ruby and python'

  s.add_dependency('ffi', [">= 0.6.3"])
  s.add_dependency('blankslate', [">= 2.1.2.3"])

  s.add_development_dependency('rspec', [">= 2.0"])
end

