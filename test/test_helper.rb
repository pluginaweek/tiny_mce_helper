# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

EXPANDED_RAILS_ROOT = File.expand_path(Rails.root)

class Test::Unit::TestCase #:nodoc:
  protected
    def live?
      ENV['LIVE']
    end
    
    def assert_html_equal(expected, actual)
      assert_equal expected.strip.gsub(/\n\s*/, ''), actual.strip.gsub(/\n\s*/, '')
    end
end
