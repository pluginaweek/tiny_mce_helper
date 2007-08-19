# Install TinyMCE
puts 'Installing TinyMCE...'
PluginAWeek::Helpers::TinyMCEHelper.install(ENV['VERSION'], ENV['TARGET'])

# Update the configuration options
puts 'Updating TinyMCE configuration options...'
PluginAWeek::Helpers::TinyMCEHelper.update_options
