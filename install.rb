# Install TinyMCE
puts 'Installing TinyMCE...'
TinyMCEHelper.install(:version => ENV['VERSION'], :target => ENV['TARGET'])

# Update the configuration options
puts 'Updating TinyMCE configuration options...'
TinyMCEHelper.update_options
