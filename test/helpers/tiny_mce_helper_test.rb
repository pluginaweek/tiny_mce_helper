require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TinyMceHelperTest < ActionView::TestCase
  tests PluginAWeek::TinyMCEHelper
  
  def setup
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

class TinyMceHelperScriptTest < ActionView::TestCase
  tests PluginAWeek::TinyMCEHelper
  
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
