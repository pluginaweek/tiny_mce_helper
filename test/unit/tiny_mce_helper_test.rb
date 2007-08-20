require File.dirname(__FILE__) + '/../test_helper'

# Don't go out to the Internet if we're not live
unless ENV['LIVE']
  class << PluginAWeek::Helpers::TinyMCEHelper
    # Use pages ewe've already downloaded for Sourceforge and Wiki information
    def open(name, *rest, &block)
      if name.include?('sourceforge')
        name = 'test/files/sourceforge.html'
      elsif name.include?('wiki')
        name = 'test/files/wiki.html'
      end
      
      super      
    end
    
    # User files we've already downloaded for extracting the TinyMCE soure
    def system(cmd, *args)
      if cmd =~ /^wget .+2_0_8/
        FileUtils.cp("#{EXPANDED_RAILS_ROOT}/../../test/files/tinymce_2_0_8.tgz", '/tmp/')
      elsif cmd =~ /^wget .+2_1_1_1/
        FileUtils.cp("#{EXPANDED_RAILS_ROOT}/../../test/files/tinymce_2_1_1_1.tgz", '/tmp/')
      else
        super
      end
    end
  end
end

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

class TinyMceHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::JavaScriptHelper
  include PluginAWeek::Helpers::TinyMCEHelper
  
  def setup
    PluginAWeek::Helpers::TinyMCEHelper.verbose = true
    @uses_tiny_mce = nil
    
    # Set up config path
    @config_root = "#{RAILS_ROOT}/config"
    FileUtils.cp("#{RAILS_ROOT}/config_bak/tiny_mce_options.yml", @config_root)
    @original_config_files = Dir["#{RAILS_ROOT}/config/**/*"].sort
    
    # Set up public path
    @public_root = "#{RAILS_ROOT}/public"
    FileUtils.mkdir_p("#{RAILS_ROOT}/public/javascripts")
    
    # Track valid options
    @original_valid_options = PluginAWeek::Helpers::TinyMCEHelper.valid_options.dup
    
    # Set default STDIN value
    STDIN.gets = 'n'
    STDIN.prompted = false
    
    # Set up test request
    @request = ActionController::TestRequest.new
    @controller = ActionController::Base.new
    @controller.request = @request
    @controller.instance_eval {@_params = request.path_parameters}
    @controller.send(:initialize_current_url)
    
    # Make sure we always start in a test environment
    Object.const_set('RAILS_ENV', 'test')
  end
  
  def test_valid_options_should_not_be_empty
    assert PluginAWeek::Helpers::TinyMCEHelper.valid_options.any?
  end
  
  def test_install_should_save_latest_version_to_default_target
    PluginAWeek::Helpers::TinyMCEHelper.install(:force => true)
    
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce")
    assert File.open("#{RAILS_ROOT}/public/javascripts/tinymce/changelog").readlines.join.include?('Version 2.1.1.1')
  end
  
  def test_install_should_allow_custom_version
    PluginAWeek::Helpers::TinyMCEHelper.install(:version => '2.0.8', :force => true)
    
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce")
    assert File.open("#{RAILS_ROOT}/public/javascripts/tinymce/changelog").readlines.join.include?('Version 2.0.8')
  end
  
  def test_install_should_allow_custom_target
    PluginAWeek::Helpers::TinyMCEHelper.install(:target => 'public/javascripts/tiny_mce', :force => true)
    
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tiny_mce")
  end
  
  def test_install_should_prompt_user_if_base_target_already_exists
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    PluginAWeek::Helpers::TinyMCEHelper.install
    
    assert STDIN.prompted
  end
  
  def test_install_should_skip_if_target_exists_and_user_skips
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    STDIN.gets = 'n'
    PluginAWeek::Helpers::TinyMCEHelper.install
    
    assert !File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce/changelog")
  end
  
  def test_install_should_not_skip_if_target_exists_and_user_doesnt_skip
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    STDIN.gets = 'y'
    PluginAWeek::Helpers::TinyMCEHelper.install
    
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce/changelog")
  end
  
  def test_install_should_continue_prompting_user_if_target_exists_and_invalid_option_is_typed
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    STDIN.gets = %w(k y)
    PluginAWeek::Helpers::TinyMCEHelper.install
    
    assert STDIN.gets.chomp.empty?
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce/changelog")
  end
  
  def test_install_should_overwrite_existing_folder_if_forced
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    PluginAWeek::Helpers::TinyMCEHelper.install(:force => true)
    
    assert File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce/changelog")
  end
  
  def test_uninstall_should_remove_options_configuration
    PluginAWeek::Helpers::TinyMCEHelper.uninstall
    assert !File.exists?("#{RAILS_ROOT}/config/tiny_mce_options.yml")
  end
  
  def test_uninstall_should_remove_tinymce_source
    FileUtils.mkdir("#{RAILS_ROOT}/public/javascripts/tinymce")
    PluginAWeek::Helpers::TinyMCEHelper.uninstall
    
    assert !File.exists?("#{RAILS_ROOT}/public/javascripts/tinymce")
  end
  
  def test_should_update_options_if_options_configuration_doesnt_exist
    FileUtils.rm("#{RAILS_ROOT}/config/tiny_mce_options.yml")
    PluginAWeek::Helpers::TinyMCEHelper.update_options
    
    assert File.exists?("#{RAILS_ROOT}/config/tiny_mce_options.yml")
    options = File.open(PluginAWeek::Helpers::TinyMCEHelper::OPTIONS_FILE_PATH) {|f| YAML.load(f.read)}
    assert_instance_of Array, options
  end
  
  def test_should_update_options_if_options_configuration_exists
    File.truncate("#{RAILS_ROOT}/config/tiny_mce_options.yml", 0)
    PluginAWeek::Helpers::TinyMCEHelper.update_options
    
    assert File.exists?("#{RAILS_ROOT}/config/tiny_mce_options.yml")
    options = File.open(PluginAWeek::Helpers::TinyMCEHelper::OPTIONS_FILE_PATH) {|f| YAML.load(f.read)}
    assert_instance_of Array, options
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
    Object.const_set('RAILS_ENV', 'development')
    assert_equal 'tinymce/tiny_mce_src', tiny_mce_file_name
  end
  
  def test_should_use_compressed_file_name_if_in_test
    Object.const_set('RAILS_ENV', 'test')
    assert_equal 'tinymce/tiny_mce', tiny_mce_file_name
  end
  
  def test_should_use_compressed_file_name_if_in_production
    Object.const_set('RAILS_ENV', 'production')
    assert_equal 'tinymce/tiny_mce', tiny_mce_file_name
  end
  
  def test_should_use_environment_file_name_for_javascript_include_in_development
    Object.const_set('RAILS_ENV', 'development')
    assert_equal '<script src="/javascripts/tinymce/tiny_mce_src.js" type="text/javascript"></script>', javascript_include_tiny_mce
  end
  
  def test_should_use_environment_file_name_for_javascript_include_in_test
    Object.const_set('RAILS_ENV', 'test')
    assert_equal '<script src="/javascripts/tinymce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce
  end
  
  def test_should_include_conditional_javascript_if_using_tiny_mce
    @uses_tiny_mce = true
    assert_equal '<script src="/javascripts/tinymce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce_if_used
  end
  
  def test_should_not_include_conditional_javascript_if_not_using_tiny_mce
    @uses_tiny_mce = false
    assert_nil javascript_include_tiny_mce_if_used
  end
  
  def test_script_should_use_textareas_mode_and_simple_theme_by_default
    expected = <<-end_eval
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script
  end
  
  def test_script_should_raise_exception_if_invalid_option_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_nil
    PluginAWeek::Helpers::TinyMCEHelper.valid_options = nil
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_empty
    PluginAWeek::Helpers::TinyMCEHelper.valid_options = []
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_script_should_not_raise_exception_for_dynamic_options
    assert_nothing_raised {tiny_mce_init_script(:theme_advanced_buttons_1 => '', :theme_advanced_container_test => '')}
  end
  
  def test_script_should_convert_symbols
    expected = <<-end_eval
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script(:mode => :textareas)
  end
  
  def test_script_should_convert_numbers
    expected = <<-end_eval
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        width : '640'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script(:width => 640)
  end
  
  def test_script_should_convert_arrays
    expected = <<-end_eval
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        valid_elements : 'b,p,br,i,u'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script(:valid_elements => %w(b p br i u))
  end
  
  def test_script_should_convert_boolean_true
    expected = <<-end_eval
      tinyMCE.init({
        auto_reset_designmode : true,
        mode : 'textareas',
        theme : 'simple'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => true)
  end
  
  def test_script_should_convert_boolean_false
    expected = <<-end_eval
      tinyMCE.init({
        auto_reset_designmode : false,
        mode : 'textareas',
        theme : 'simple'
      });
    end_eval
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => false)
  end
  
  def test_script_should_raise_exception_if_unknown_value_class_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:mode => Hash.new)}
  end
  
  def test_tiny_mce_should_wrap_script_in_javascript_tag
    expected = <<-end_eval
      <script type="text/javascript">
      //<![CDATA[
        tinyMCE.init({
          mode : 'textareas',
          theme : 'simple'
        });
      //]]>
      </script>
    end_eval
    assert_html_equal expected, tiny_mce
  end
  
  def teardown
    FileUtils.rmtree(@public_root)
    PluginAWeek::Helpers::TinyMCEHelper.valid_options = @original_valid_options
  end
end
