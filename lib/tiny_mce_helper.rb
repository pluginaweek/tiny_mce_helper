module PluginAWeek #:nodoc:
  module Helpers #:nodoc:
    # Adds helper methods for generating the TinyMCE initialization script
    # within your Rails views
    module TinyMCEHelper
      # The path to the file which contains all valid options that can be used
      # to configure TinyMCE
      OPTIONS_FILE_PATH = "#{RAILS_ROOT}/config/tiny_mce_options.yml"
      
      # A list of all valid options that can be used to configure TinyMCE
      mattr_accessor :valid_options
      @@valid_options = File.exists?(OPTIONS_FILE_PATH) ? File.open(OPTIONS_FILE_PATH) {|f| YAML.load(f.read)} : []
      
      class << self
        # Installs TinyMCE by downloading it and adding it to your application's
        # javascripts folder.
        # 
        # == Versions
        # 
        # By default, this will install the latest version of TinyMCE.  You can
        # install a specific version of TinyMCE (if you are using an old API) by
        # passing in the version number.
        # 
        # For example,
        #   PluginAWeek::Helpers::TinyMCEHelper.install           #=> Installs the latest version
        #   PluginAWeek::Helpers::TinyMCEHelper.install('2.0.8')  #=> Installs version 2.0.8
        # 
        # An exception will be raised if the specified version cannot be found.
        # 
        # == Target path
        # 
        # By default, this will install TinyMCE into RAILS_ROOT/public/javascripts/tinymce.
        # If you want to install it to a different directory, you can pass in
        # a parameter with the relative path from RAILS_ROOT.
        # 
        # For example,
        #   PluginAWeek::Helpers::TinyMCEHelper.install(nil, 'public/javascripts/richtext')
        def install(version = nil, base_target = nil, force = false)
          base_target ||= 'public/javascripts/tinymce'
          source_path = 'tinymce'
          target_path = File.join(RAILS_ROOT, base_target)
          
          # If TinyMCE is already installed, make sure the user wants to continue
          if !force && File.exists?(target_path)
            print "TinyMCE already be installed in #{target_path}. Overwrite? (y/n): "
            while !%w(y n).include?(option = STDIN.gets.chop)
              print "Invalid option. Overwrite #{target_path}? (y/n): "
            end
            return if option == 'n'
          end
          
          require 'hpricot'
          require 'open-uri'
          
          # Get the url of the TinyMCE version
          doc = Hpricot(open('http://sourceforge.net/project/showfiles.php?group_id=103281&package_id=111430'))
          if version
            version.gsub!('.', '_')
            file_element = (doc/'tr[@id*="rel0_"] a').detect {|file| file.innerHTML =~ /#{version}.tgz$/}
            raise ArgumentError, "Could not find TinyMCE version #{version}" if !file_element
          else
            file_element = (doc/'tr[@id^="pkg0_1rel0_"] a').detect {|file| file.innerHTML.to_s =~ /\d\.tgz$/}
            raise ArgumentError, 'Could not find latest TinyMCE version' if !file_element
          end
          
          filename = file_element.innerHTML
          file_url = file_element['href']
          
          # Download and install it
          Dir.chdir('/tmp/') do
            begin
              puts 'Downloading TinyMCE source...'
              system("wget '#{file_url}' &> wget.log")
              puts 'Extracting...'
              system("tar xf #{filename} &> tar.log")
              File.delete(filename)
              FileUtils.mkdir_p(target_path)
              FileUtils.mv(source_path, target_path, :force => true)
              puts 'Done!'
            rescue Object => e
              puts "Error: See the last modified log file (wget.log or tar.log) in /tmp/."
            end
          end
        end
        
        # Updates the list of possible configuration options that can be used
        # when initializing the TinyMCE script.  These are always installed to
        # the application folder, config/tiny_mce_options.yml.  If this file
        # does not exist, then the TinyMCE helper will not be able to verify
        # that all of the initialization options are valid.
        def update_options
          require 'hpricot'
          require 'open-uri'
          require 'yaml'
          
          puts 'Downloading configuration options from TinyMCE Wiki...'
          doc = Hpricot(open('http://wiki.moxiecode.com/index.php/TinyMCE:Configuration'))
          options = (doc/'a[@title*="Configuration/"]/').collect {|option| option.to_s}.sort
          options.reject! {|option| option =~ /theme_advanced_buttons|theme_advanced_container/}
          
          File.open('config/tiny_mce_options.yml', 'w') do |out|
            YAML.dump(options, out)
          end
          puts 'Done!'
        end
      end
      
      # Are we using TinyMCE?
      def using_tiny_mce?
        !@uses_tiny_mce.nil?
      end
      
      # Create the TinyMCE initialization scripts.  The default configuration
      # is for a simple theme that replaces all textareas on the page.  For
      # example, the default initialization script will generate the following:
      # 
      #  tinyMCE.init({
      #    'mode' : 'textareas',
      #    'theme' : 'simple'
      #  });
      # 
      # == Customizing initialization options
      # 
      # To customize the options to be included in the initialization script,
      # you can pass in a hash to #tiny_mce_init_script.  For example,
      # 
      #   tiny_mce_init_script(
      #     :theme => 'advanced',
      #     :editor_selector => 'rich_text',
      #     :content_css => '/stylesheets/tiny_mce_content.css',
      #     :editor_css => '/stylesheets/tiny_mce_editor.css',
      #     :auto_reset_designmode => true
      #   )
      # 
      # will generate:
      # 
      #  tinyMCE.init({
      #    'mode' : 'textareas',
      #    'theme' : 'advanced',
      #    'editor_selected' : 'rich_text',
      #    'content_css' : '/stylesheets/tiny_mce_content.css'
      #  });
      # 
      # == Validating options
      # 
      # If additional options are passed in to initialize TinyMCE, they will be
      # validated against the list of valid options in PluginAWeek::Helpers::TinyMCEHelper#valid_options.
      # These options are configured in the file config/tiny_mce_options.yml.
      # You can generate this file by invoke the rake task tiny_mce:update_options.
      def tiny_mce_init_script(options = @tiny_mce_options)
        options ||= {}
        options.stringify_keys!.reverse_merge!(
           'mode' => 'textareas',
           'theme' => 'simple'
        )
        
        # Check validity
        plugins = options['plugins']
        options_to_validate = options.reject {|option, value| plugins && plugins.include?(option.split('_')[0]) || option =~ /theme_advanced_container_/}
        options_to_validate.assert_valid_keys(@@valid_options) if @@valid_options.any?
        
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
              raise ArgumentError, "Cannot parse value of type #{value.class} passed for TinyMCE option #{key}"
          end
          
          init_script << ','
        end
        
        init_script.chop << "\n});"
      end
      
      # Generate the TinyMCE 
      def tiny_mce(*args)
        javascript_tag tiny_mce_init_script(*args)
      end
      
      # The name of the TinyMCE javascript file to use.  In development, this
      # will use the source (uncompressed) file in order to help with debugging
      # issues that occur within TinyMCE.  In production, the compressed version
      # of TinyMCE will be used in order to increased download speed.
      def tiny_mce_file_name
        RAILS_ENV == 'development' ? 'tinymce/tiny_mce_src' : 'tinymce/tiny_mce'
      end
      
      # Generates the javascript include for TinyMCE.  For example,
      # 
      #   javascript_include_tiny_mce
      # 
      # will generate:
      # 
      #   <script type="text/javascript" src="/javascripts/tinymce/tiny_mce.js"></script>
      def javascript_include_tiny_mce
        javascript_include_tag tiny_mce_file_name
      end
      
      # Conditionally includes the TinyMCE javascript file if the variable
      # @uses_tiny_mce has been set to true.
      def javascript_include_tiny_mce_if_used
        javascript_include_tiny_mce if using_tiny_mce?
      end
    end
  end
end

ActionController::Base.class_eval do
  helper PluginAWeek::Helpers::TinyMCEHelper
end
