namespace :tiny_mce do
  desc 'Downloads the TinyMCE and installs it in the application. Target specific version with VERSION=x, specific target path with TARGET=y'
  task :install => :environment do
    PluginAWeek::Helpers::TinyMCEHelper.install(ENV['VERSION'], ENV['TARGET'])
  end
  
  desc 'Downloads the TinyMCE and installs it in the application. Target specific version with VERSION=x, specific target path with TARGET=y'
  task :update => :environment do
    PluginAWeek::Helpers::TinyMCEHelper.install(ENV['VERSION'], ENV['TARGET'], true)
  end
  
  desc 'Updates the list of TinyMCE options and stores them in config/tiny_mce_options.yml.'
  task :update_options => :environment do
    PluginAWeek::Helpers::TinyMCEHelper.update_options
  end
end
