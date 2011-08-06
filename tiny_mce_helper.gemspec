$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'tiny_mce_helper/version'

Gem::Specification.new do |s|
  s.name              = "tiny_mce_helper"
  s.version           = TinyMCEHelper::VERSION
  s.authors           = ["Aaron Pfeifer"]
  s.email             = "aaron@pluginaweek.org"
  s.homepage          = "http://www.pluginaweek.org"
  s.description       = "Adds helper methods for creating the TinyMCE initialization script in Rails"
  s.summary           = "TinyMCE helpers in Rails"
  s.require_paths     = ["lib"]
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- test/*`.split("\n")
  s.rdoc_options      = %w(--line-numbers --inline-source --title tiny_mce_helper --main README.rdoc)
  s.extra_rdoc_files  = %w(README.rdoc CHANGELOG.rdoc)
end
