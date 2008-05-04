# Install TinyMCE
puts 'Installing TinyMCE...'
PluginAWeek::TinyMCEHelper.install(:version => ENV['VERSION'], :target => ENV['TARGET'])

# Update the configuration options
puts 'Updating TinyMCE configuration options...'
PluginAWeek::TinyMCEHelper.update_options
