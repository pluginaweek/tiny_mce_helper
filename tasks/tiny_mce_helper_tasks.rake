namespace :tiny_mce do
  desc 'Downloads TinyMCE and installs it in the application. Target specific version with VERSION=x, specific target path with TARGET=y'
  task :install => :environment do
    PluginAWeek::TinyMCEHelper.install(:version => ENV['VERSION'], :target => ENV['TARGET'])
  end
  
  desc 'Downloads TinyMCE and installs it in the application. Target specific version with VERSION=x, specific target path with TARGET=y'
  task :update => :environment do
    PluginAWeek::TinyMCEHelper.install(:version => ENV['VERSION'], :target => ENV['TARGET'], :force => true)
  end
  
  desc 'Uninstalls TinyMCE and removes any associated configuration files.'
  task :uninstall => :environment do
    PluginAWeek::TinyMCEHelper.uninstall(:target => ENV['TARGET'])
  end
  
  desc 'Updates the list of TinyMCE options and stores them in config/tiny_mce_options.yml.'
  task :update_options => :environment do
    PluginAWeek::TinyMCEHelper.update_options
  end
end
