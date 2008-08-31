require File.dirname(__FILE__) + '/../test_helper'

# Don't go out to the Internet if we're not live
class << PluginAWeek::TinyMCEHelper
  # Whether or not an IO failure should be caused
  attr_accessor :fail_io
  
  # Use pages we've already downloaded for Sourceforge and Wiki information
  def open(name, *rest, &block)
    name = case name
      when /showfiles/
        'test/files/sourceforge.html'
      when /wiki/
        'test/files/wiki.html'
      when /3_0_8/
        "#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_8.zip"
      when /3_0_6_2/
        "#{EXPANDED_RAILS_ROOT}/../files/tinymce_3_0_6_2.zip"
      else
        name
    end
    
    super      
  end
end unless ENV['LIVE']

# Simulate user input
class << STDIN
  attr_accessor :prompted
  
  def gets
    @prompted = true
    "#{@gets.is_a?(Array) ? @gets.shift : @gets}\n"
  end
  
  def gets=(value)
    @gets = value
  end
end

class TinyMceInstallerTest < Test::Unit::TestCase
  def setup
    # Set up public path
    FileUtils.mkdir_p("#{Rails.root}/public/javascripts")
    
    # Set default STDIN value
    STDIN.gets = 'n'
    STDIN.prompted = false
  end
  
  def test_should_save_latest_version_to_default_target
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
    PluginAWeek::TinyMCEHelper.install(:version => '3.0.6.2', :force => true)
    
    assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce")
    
    source = File.read("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
    assert source.include?("majorVersion : '3'");
    assert source.include?("minorVersion : '0.6.2'");
  end
  
  def test_should_allow_custom_target
    PluginAWeek::TinyMCEHelper.install(:target => 'public/javascripts/tinymce', :force => true)
    
    assert File.exists?("#{Rails.root}/public/javascripts/tinymce")
  end
  
  def test_should_prompt_user_if_base_target_already_exists
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    PluginAWeek::TinyMCEHelper.install
    
    assert STDIN.prompted
  end
  
  def test_should_skip_if_target_exists_and_user_skips
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    STDIN.gets = 'n'
    PluginAWeek::TinyMCEHelper.install
    
    assert !File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
  end
  
  def test_should_not_skip_if_target_exists_and_user_doesnt_skip
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    STDIN.gets = 'y'
    PluginAWeek::TinyMCEHelper.install
    
    assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
  end
  
  def test_should_continue_prompting_user_if_target_exists_and_invalid_option_is_typed
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    STDIN.gets = %w(k y)
    PluginAWeek::TinyMCEHelper.install
    
    assert STDIN.gets.chomp.empty?
    assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
  end
  
  def test_install_should_overwrite_existing_folder_if_forced
    FileUtils.mkdir("#{Rails.root}/public/javascripts/tiny_mce")
    PluginAWeek::TinyMCEHelper.install(:force => true)
    
    assert File.exists?("#{Rails.root}/public/javascripts/tiny_mce/tiny_mce_src.js")
  end
  
  def test_should_not_raise_exception_if_error_occurs_during_io_operation
    PluginAWeek::TinyMCEHelper.fail_io = true unless live?
    
    assert_nothing_raised  {PluginAWeek::TinyMCEHelper.install(:force => true)}
  ensure
    PluginAWeek::TinyMCEHelper.fail_io = false unless live?
  end
  
  def teardown
    FileUtils.rm_rf("#{Rails.root}/public")
  end
end

class TinyMceUpdaterTest < Test::Unit::TestCase
  def setup
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

class TinyMceHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::JavaScriptHelper
  include PluginAWeek::TinyMCEHelper
  
  def setup
    # Set up test request
    @request = ActionController::TestRequest.new
    @controller = ActionController::Base.new
    @controller.request = @request
    @controller.instance_eval {@_params = request.path_parameters}
    @controller.send(:initialize_current_url)
    
    # Make sure we always start in a test environment
    silence_warnings {Object.const_set('RAILS_ENV', 'test')}
  end
  
  def test_valid_options_should_not_be_empty
    assert PluginAWeek::TinyMCEHelper.valid_options.any?
  end
  
  def test_should_be_using_tiny_mce_if_instance_variable_exists
    @uses_tiny_mce = true
    assert using_tiny_mce?
  end
  
  def test_should_not_be_using_tiny_mce_if_instance_variable_doesnt_exist
    @uses_tiny_mce = false
    assert !using_tiny_mce?
  end
  
  def test_should_use_source_file_name_if_in_development
    silence_warnings {Object.const_set('RAILS_ENV', 'development')}
    assert_equal 'tiny_mce/tiny_mce_src', tiny_mce_file_name
  end
  
  def test_should_use_compressed_file_name_if_in_test
    silence_warnings {Object.const_set('RAILS_ENV', 'test')}
    assert_equal 'tiny_mce/tiny_mce', tiny_mce_file_name
  end
  
  def test_should_use_compressed_file_name_if_in_production
    silence_warnings {Object.const_set('RAILS_ENV', 'production')}
    assert_equal 'tiny_mce/tiny_mce', tiny_mce_file_name
  end
  
  def test_should_use_environment_file_name_for_javascript_include_in_development
    silence_warnings {Object.const_set('RAILS_ENV', 'development')}
    assert_equal '<script src="/javascripts/tiny_mce/tiny_mce_src.js" type="text/javascript"></script>', javascript_include_tiny_mce
  end
  
  def test_should_use_environment_file_name_for_javascript_include_in_test
    silence_warnings {Object.const_set('RAILS_ENV', 'test')}
    assert_equal '<script src="/javascripts/tiny_mce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce
  end
  
  def test_should_include_conditional_javascript_if_using_tiny_mce
    @uses_tiny_mce = true
    assert_equal '<script src="/javascripts/tiny_mce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce_if_used
  end
  
  def test_should_not_include_conditional_javascript_if_not_using_tiny_mce
    @uses_tiny_mce = false
    assert_nil javascript_include_tiny_mce_if_used
  end
end

class TinyMceHelperScriptTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::JavaScriptHelper
  include PluginAWeek::TinyMCEHelper
  
  def setup
    # Track valid options
    @original_valid_options = PluginAWeek::TinyMCEHelper.valid_options.dup
  end
  
  def test_script_should_use_textareas_mode_and_simple_theme_by_default
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script
  end
  
  def test_script_should_raise_exception_if_invalid_option_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_nil
    PluginAWeek::TinyMCEHelper.valid_options = nil
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_empty
    PluginAWeek::TinyMCEHelper.valid_options = []
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_for_dynamic_options
    assert_nothing_raised {tiny_mce_init_script(:theme_advanced_buttons_1 => '', :theme_advanced_container_test => '')}
  end
  
  def test_script_should_convert_symbols
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:mode => :textareas)
  end
  
  def test_script_should_convert_numbers
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        width : '640'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:width => 640)
  end
  
  def test_script_should_convert_arrays
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        valid_elements : 'b,p,br,i,u'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:valid_elements => %w(b p br i u))
  end
  
  def test_script_should_convert_boolean_true
    expected = <<-end_str
      tinyMCE.init({
        auto_reset_designmode : true,
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => true)
  end
  
  def test_script_should_convert_boolean_false
    expected = <<-end_str
      tinyMCE.init({
        auto_reset_designmode : false,
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => false)
  end
  
  def test_script_should_raise_exception_if_unknown_value_class_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:mode => Hash.new)}
  end
  
  def test_tiny_mce_should_wrap_script_in_javascript_tag
    expected = <<-end_str
      <script type="text/javascript">
      //<![CDATA[
        tinyMCE.init({
          mode : 'textareas',
          theme : 'simple'
        });
      //]]>
      </script>
    end_str
    assert_html_equal expected, tiny_mce
  end
  
  def teardown
    PluginAWeek::TinyMCEHelper.valid_options = @original_valid_options
  end
end
