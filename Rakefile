require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run all tests.'
task :default => :test

desc "Test tiny_mce_helper."
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = Dir['test/**/*_test.rb']
  t.verbose = true
end

begin
  require 'rcov/rcovtask'
  namespace :test do
    desc "Test tiny_mce_helper with Rcov."
    Rcov::RcovTask.new(:rcov) do |t|
      t.libs << 'lib'
      t.test_files = Dir['test/**/*_test.rb']
      t.rcov_opts << '--exclude="^(?!lib/)"'
      t.verbose = true
    end
  end
rescue LoadError
end

desc "Generate documentation for tiny_mce_helper."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'tiny_mce_helper'
  rdoc.options << '--line-numbers' << '--inline-source' << '--main=README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'CHANGELOG.rdoc', 'lib/**/*.rb')
end
