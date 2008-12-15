require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TinyMceHelperTest < ActionView::TestCase
  tests TinyMCEHelper
  
  def test_valid_options_should_not_be_empty
    assert TinyMCEHelper.valid_options.any?
  end
end

uses_mocha 'stubbing Rails.env' do
  class TinyMceHelperFilenameTest < ActionView::TestCase
    tests TinyMCEHelper
    
    def test_should_use_source_file_name_if_in_development
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('development'))
      assert_equal 'tiny_mce/tiny_mce_src', tiny_mce_file_name
    end
    
    def test_should_use_compressed_file_name_if_in_test
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('test'))
      assert_equal 'tiny_mce/tiny_mce', tiny_mce_file_name
    end
    
    def test_should_use_compressed_file_name_if_in_production
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))
      assert_equal 'tiny_mce/tiny_mce', tiny_mce_file_name
    end
    
    def test_should_use_environment_file_name_for_javascript_include_in_development
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('development'))
      assert_equal '<script src="/javascripts/tiny_mce/tiny_mce_src.js" type="text/javascript"></script>', javascript_include_tiny_mce
    end
    
    def test_should_use_environment_file_name_for_javascript_include_in_test
      Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('test'))
      assert_equal '<script src="/javascripts/tiny_mce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce
    end
  end
end

class TinyMceHelperDisabledTest < ActionView::TestCase
  tests TinyMCEHelper
  
  def setup
    @uses_tiny_mce = false
  end
  
  def test_should_not_be_using_tiny_mce
    assert !using_tiny_mce?
  end
  
  def test_should_not_include_conditional_javascript
    assert_nil javascript_include_tiny_mce_if_used
  end
end

class TinyMceHelperEnabledTest < ActionView::TestCase
  tests TinyMCEHelper
  
  def setup
    @uses_tiny_mce = true
  end
  
  def test_should_be_using_tiny_mce
    assert using_tiny_mce?
  end
  
  def test_should_include_conditional_javascript
    assert_equal '<script src="/javascripts/tiny_mce/tiny_mce.js" type="text/javascript"></script>', javascript_include_tiny_mce_if_used
  end
end

class TinyMceHelperScriptTest < ActionView::TestCase
  tests TinyMCEHelper
  
  def setup
    # Track valid options
    @original_valid_options = TinyMCEHelper.valid_options.dup
  end
  
  def test_should_use_textareas_mode_and_simple_theme_by_default
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script
  end
  
  def test_should_raise_exception_if_invalid_option_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_nil
    TinyMCEHelper.valid_options = nil
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_should_not_raise_exception_if_invalid_option_provided_but_valid_options_is_empty
    TinyMCEHelper.valid_options = []
    assert_nothing_raised {tiny_mce_init_script(:invalid => true)}
  end
  
  def test_should_not_raise_exception_for_dynamic_options
    assert_nothing_raised {tiny_mce_init_script(:theme_advanced_buttons_1 => '', :theme_advanced_container_test => '')}
  end
  
  def test_should_convert_symbols_to_strings
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:mode => :textareas)
  end
  
  def test_should_convert_numbers_to_strings
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        width : '640'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:width => 640)
  end
  
  def test_should_convert_arrays_to_comma_delimited_values
    expected = <<-end_str
      tinyMCE.init({
        mode : 'textareas',
        theme : 'simple',
        valid_elements : 'b,p,br,i,u'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:valid_elements => %w(b p br i u))
  end
  
  def test_should_convert_true_to_boolean
    expected = <<-end_str
      tinyMCE.init({
        auto_reset_designmode : true,
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => true)
  end
  
  def test_should_convert_false_to_boolean
    expected = <<-end_str
      tinyMCE.init({
        auto_reset_designmode : false,
        mode : 'textareas',
        theme : 'simple'
      });
    end_str
    assert_html_equal expected, tiny_mce_init_script(:auto_reset_designmode => false)
  end
  
  def test_should_raise_exception_if_unknown_value_class_provided
    assert_raise(ArgumentError) {tiny_mce_init_script(:mode => {})}
  end
  
  def teardown
    TinyMCEHelper.valid_options = @original_valid_options
  end
end

class TinyMceHelperScriptTagTest
  def test_should_wrap_script_in_javascript_tag
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
end
