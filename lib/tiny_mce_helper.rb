module PluginAWeek
  module Helpers
    #
    module TinyMCEHelper
      mattr_accessor :valid_options
      @@valid_options =
        # General
        %w(
           mode
           theme
           plugins
           language
           ask
           textarea_trigger
           editor_selector
           editor_deselector
           elements
           docs_language
           debug
           focus_alert
           directionality
           auto_reset_designmode
           auto_focus
           nowrap
           button_tile_map
           auto_resize
           browsers
           dialog_type
           accessibility_warnings
           accessibility_focus
           event_elements
           table_inline_editing
           object_resizing
           custom_shortcuts
           strict_loading_mode
           gecko_spellcheck
           hide_selects_on_submit
        ) +
        
        # Callbacks
        %w(
          urlconverter_callback
          insertlink_callback
          insertimage_callback
          setupcontent_callback
          save_callback
          onchange_callback
          init_instance_callback
          file_browser_callback
          cleanup_callback
          handle_event_callback
          execcommand_callback
          oninit
          onpageload
        ) + 
        
        # Cleanup/Output
        %w(
          cleanup
          valid_elements
          extended_valid_elements
          invalid_elements
          verify_css_classes
          verify_html
          preformatted
          encoding
          cleanup_on_startup
          fix_content_duplication
          inline_styles
          convert_newlines_to_brs
          force_br_newlines
          force_p_newlines
          entities
          entity_encoding
          remove_linebreaks
          convert_fonts_to_spans
          font_size_classes
          font_size_style_values
          merge_styles_invalid_parents
          force_hex_style_colors
          apply_source_formatting
          trim_span_elements
          doctype
          fix_list_elements
          fix_table_elements
          valid_child_elements
          cleanup_serializer
        ) + 
        
        # URL
        %w(
          convert_urls
          relative_urls
          remove_script_host
          document_base_url
        ) + 
        
        # Layout
        %w(
          content_css
          popups_css
          popups_css_add
          editor_css
          width
          height
        ) + 
        
        # Visual aids
        %w(
          visual
          visual_table_class
        ) + 
        
        # Undo/Redo
        %w(
          custom_undo_redo
          custom_undo_redo_levels
          custom_undo_redo_keyboard_shortcuts
          custom_undo_redo_restore_selection
        ) + 
        
        # File lists
        %w(
          external_link_list_url
          external_image_list_url
        ) + 
        
        # Tab specific
        %w(
          display_tab_class
          hidden_tab_class
        ) + 
        
        # Triggers/patches
        %w(
          add_form_submit_trigger
          add_unload_trigger
          submit_patch
        ) + 
        
        # Advanced theme
        %w(
          theme_advanced_layout_manager
          theme_advanced_blockformats
          theme_advanced_styles
          theme_advanced_source_editor_width
          theme_advanced_source_editor_height
          theme_advanced_source_editor_wrap
          theme_advanced_toolbar_location
          theme_advanced_toolbar_align
          theme_advanced_statusbar_location
          theme_advanced_buttons1
          theme_advanced_buttons1_add
          theme_advanced_buttons1_add_before
          theme_advanced_buttons2
          theme_advanced_buttons2_add
          theme_advanced_buttons2_add_before
          theme_advanced_buttons3
          theme_advanced_buttons3_add
          theme_advanced_buttons3_add_before
          theme_advanced_disable
          theme_advanced_containers
          theme_advanced_containers_default_class
          theme_advanced_containers_default_align
          theme_advanced_container_<container>
          theme_advanced_container_<container>_class
          theme_advanced_container_<container>_align
          theme_advanced_custom_layout
          theme_advanced_link_targets
          theme_advanced_resizing
          theme_advanced_resizing_use_cookie
          theme_advanced_resize_horizontal
          theme_advanced_path
          theme_advanced_fonts
          theme_advanced_text_colors
          theme_advanced_background_colors
        )
        
      # Are we using TinyMCE?
      def using_tiny_mce?
        !@uses_tiny_mce.nil?
      end
      
      # Create the script that will initialize TinyMCE
      def tiny_mce_init_script(options = @tiny_mce_options)
        options ||= {}
        options.stringify_keys!.reverse_merge!(
           'mode' => 'textareas',
           'theme' => 'simple'
        )
        
        # Check validity
        plugins = options[:plugins]
        options_to_validate = options.reject {|option, value| plugins.include?(option.split('_')[0]) || option =~ /theme_advanced_container_/}
        options_to_validate.assert_valid_keys(@@valid_options)
        
        init_script = 'tinyMCE.init({'
        
        options.sort.each do |key, value|
          init_script += "\n#{key} : "
          
          case value
            when String, Symbol, Fixnum
              init_script << "'#{value}'"
            when Array
              init_script << '"' + value.join(',') + '"'
            when TrueClass
              init_script << 'true'
            when FalseClass
              init_script << 'false'
            else
              raise InvalidOption.new("Invalid value of type #{value.class} passed for TinyMCE option #{key}")
          end
          
          init_script << ','
        end
        
        init_script.chop << "\n});"
      end
      
      # Generate the TinyMCE 
      def tiny_mce(*args)
        javascript_tag tiny_mce_init_script(*args)
      end
      
      def tiny_mce_file_name
        RAILS_ENV == 'development' ? 'tiny_mce/tiny_mce_src' : 'tiny_mce/tiny_mce'
      end
      
      def javascript_include_tiny_mce
        javascript_include_tag tiny_mce_file_name
      end
      
      def javascript_include_tiny_mce_if_used
        javascript_include_tiny_mce if @uses_tiny_mce
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TinyMCEHelper
end