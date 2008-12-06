# Setup default folders
require 'fileutils'
FileUtils.rm_rf('test/app_root/config')
FileUtils.cp_r('test/app_root/config_bak', 'test/app_root/config')

# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

EXPANDED_RAILS_ROOT = File.expand_path(Rails.root)

Test::Unit::TestCase.class_eval do
  protected
    def live?
      ENV['LIVE']
    end
    
    def assert_html_equal(expected, actual)
      assert_equal expected.strip.gsub(/\n\s*/, ''), actual.strip.gsub(/\n\s*/, '')
    end
end

# Allow skipping of tests that require mocha
def uses_mocha(description)
  require 'rubygems'
  require 'mocha'
  yield
rescue LoadError
  $stderr.puts "Skipping #{description} tests. `gem install mocha` and try again."
end
