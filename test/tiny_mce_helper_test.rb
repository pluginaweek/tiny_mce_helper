require File.dirname(__FILE__) + '/test_helper'

class TinyMceHelperTest < Test::Unit::TestCase
  include PluginAWeek::Helpers::TinyMCEHelper
  
  def setup
    @config_root = "#{RAILS_ROOT}/config"
    FileUtils.cp_r("#{RAILS_ROOT}/config_bak", @config_root)
    @original_config_files = Dir["#{RAILS_ROOT}/config/**/*"].sort
    
    @public_root = "#{RAILS_ROOT}/public"
    FileUtils.cp_r("#{RAILS_ROOT}/public_bak", @public_root)
    @original_public_files = Dir["#{RAILS_ROOT}/public/**/*"].sort
  end
  
  def test_valid_options_should_not_be_empty
    assert PluginAWeek::Helpers::TinyMCEHelper.valid_options.any?
  end
  
  def test_should_install_latest_version_to_default_target
  end
  
  def teardown
    FileUtils.rmtree(@public_root)
  end
end
