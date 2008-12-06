require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

uses_mocha 'mocking install/update' do
  class TinyMceInstallerTest < Test::Unit::TestCase
    def setup
      PluginAWeek::TinyMCEHelper.expects(:open).with('http://sourceforge.net/project/showfiles.php?group_id=103281&package_id=111430').returns(open('test/files/sourceforge.html')) unless live?
      
      # Set up public path
      FileUtils.mkdir_p("#{Rails.root}/public/javascripts")
    end
    
    def test_should_save_latest_version_to_default_target
      PluginAWeek::TinyMCEHelper.expects(:open).with('http://downloads.sourceforge.net/tinymce/tinymce_3_0_8.zip?modtime=1209567317&big_mirror=0').yields(open("#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_8.zip")) unless live?
      PluginAWeek::TinyMCEHelper.install(:force => true)
      
      assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce")
      
      source = File.read("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
      
      if live?
        assert source.include?('tinymce')
      else
        assert source.include?("majorVersion : '3'");
        assert source.include?("minorVersion : '0.8'");
      end
    end
    
    def test_should_allow_custom_version
      PluginAWeek::TinyMCEHelper.expects(:open).with('http://downloads.sourceforge.net/tinymce/tinymce_3_0_6_2.zip?modtime=1207580953&big_mirror=0').yields(open("#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_6_2.zip")) unless live?
      PluginAWeek::TinyMCEHelper.install(:version => '3.0.6.2', :force => true)
      
      assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce")
      
      source = File.read("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
      assert source.include?("majorVersion : '3'");
      assert source.include?("minorVersion : '0.6.2'");
    end
    
    def test_should_allow_custom_target
      PluginAWeek::TinyMCEHelper.expects(:open).with('http://downloads.sourceforge.net/tinymce/tinymce_3_0_8.zip?modtime=1209567317&big_mirror=0').yields(open("#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_8.zip")) unless live?
      PluginAWeek::TinyMCEHelper.install(:target => 'public/javascripts/tinymce', :force => true)
      
      assert File.exists?("#{Rails.root}/public/javascripts/tinymce")
    end
    
    def teardown
      FileUtils.rm_rf("#{Rails.root}/public")
    end
  end

  class TinyMceInstallerExistingTest < Test::Unit::TestCase
    def setup
      # Set up public path
      FileUtils.mkdir_p("#{Rails.root}/public/javascripts/tiny_mce")
    end
    
    def test_should_prompt_user
      expects_file_requests
      
      STDIN.expects(:gets).returns("y\n")
      PluginAWeek::TinyMCEHelper.install
    end
    
    def test_should_skip_if_user_skips
      PluginAWeek::TinyMCEHelper.expects(:open).never
      
      STDIN.expects(:gets).returns("n\n")
      PluginAWeek::TinyMCEHelper.install
      
      assert !File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
    end
    
    def test_should_not_skip_if_user_does_not_skip
      expects_file_requests
      
      STDIN.expects(:gets).returns("y\n")
      PluginAWeek::TinyMCEHelper.install
      
      assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
    end
    
    def test_should_continue_prompting_user_if_invalid_response_is_typed
      expects_file_requests
      
      STDIN.expects(:gets).times(2).returns("k\n", "y\n")
      PluginAWeek::TinyMCEHelper.install
      
      assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
    end
    
    def test_should_overwrite_if_forced
      expects_file_requests
      
      STDIN.expects(:gets).never
      PluginAWeek::TinyMCEHelper.install(:force => true)
      
      assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
    end
    
    def teardown
      FileUtils.rm_rf("#{Rails.root}/public")
    end
    
    private
      def expects_file_requests
        unless live?
          PluginAWeek::TinyMCEHelper.expects(:open).with('http://sourceforge.net/project/showfiles.php?group_id=103281&package_id=111430').returns(open('test/files/sourceforge.html'))
          PluginAWeek::TinyMCEHelper.expects(:open).with('http://downloads.sourceforge.net/tinymce/tinymce_3_0_8.zip?modtime=1209567317&big_mirror=0').yields(open("#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_8.zip"))
        end
      end
  end

  class TinyMceUpdaterTest < Test::Unit::TestCase
    def setup
      PluginAWeek::TinyMCEHelper.expects(:open).with('http://wiki.moxiecode.com/index.php/TinyMCE:Configuration').returns(open('test/files/sourceforge.html')) unless live?
      
      # Track valid options
      @original_valid_options = PluginAWeek::TinyMCEHelper.valid_options.dup
    end
    
    def test_should_update_options_if_options_configuration_doesnt_exist
      FileUtils.rm("#{Rails.root}/config/tiny_mce_options.yml")
      PluginAWeek::TinyMCEHelper.update_options
      
      assert File.exists?("#{Rails.root}/config/tiny_mce_options.yml")
      options = YAML.load(File.read(PluginAWeek::TinyMCEHelper::OPTIONS_FILE_PATH))
      assert_instance_of Array, options
    end
    
    def test_should_update_options_if_options_configuration_exists
      File.truncate("#{Rails.root}/config/tiny_mce_options.yml", 0)
      PluginAWeek::TinyMCEHelper.update_options
      
      assert File.exists?("#{Rails.root}/config/tiny_mce_options.yml")
      options = YAML.load(File.open(PluginAWeek::TinyMCEHelper::OPTIONS_FILE_PATH))
      assert_instance_of Array, options
    end
    
    def teardown
      PluginAWeek::TinyMCEHelper.valid_options = @original_valid_options
      FileUtils.cp("#{Rails.root}/config_bak/tiny_mce_options.yml", "#{Rails.root}/config")
    end
  end
end

class TinyMceUninstallerTest < Test::Unit::TestCase
  def setup
    # Set up public path
    FileUtils.mkdir_p("#{Rails.root}/public/javascripts")
  end
  
  def test_uninstall_should_remove_options_configuration
    PluginAWeek::TinyMCEHelper.uninstall
    assert !File.exists?("#{Rails.root}/config/tiny_mce_options.yml")
  end
  
  def test_uninstall_should_remove_tinymce_source
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    PluginAWeek::TinyMCEHelper.uninstall
    
    assert !File.exists?("#{Rails.root}/public/javascripts/tiny_mce")
  end
  
  def teardown
    FileUtils.rm_rf("#{Rails.root}/public")
    FileUtils.cp("#{Rails.root}/config_bak/tiny_mce_options.yml", "#{Rails.root}/config")
  end
end
