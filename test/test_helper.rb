require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'

RAILS_ROOT = "#{File.dirname(__FILE__)}/app_root"
EXPANDED_RAILS_ROOT = File.expand_path(RAILS_ROOT)

$:.unshift(File.dirname(__FILE__) + '/../lib')
require File.dirname(__FILE__) + '/../init'

class Test::Unit::TestCase #:nodoc:
  private
  def assert_html_equal(expected, actual)
    assert_equal expected.strip.gsub(/\n\s*/, ''), actual.strip.gsub(/\n\s*/, '')
  end
end
