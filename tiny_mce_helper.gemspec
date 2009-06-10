# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tiny_mce_helper}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Pfeifer"]
  s.date = %q{2009-06-08}
  s.description = %q{Adds helper methods for creating the TinyMCE initialization script in Rails}
  s.email = %q{aaron@pluginaweek.org}
  s.files = ["lib/tiny_mce_helper.rb", "tasks/tiny_mce_helper_tasks.rake", "test/files", "test/files/wiki.html", "test/files/tinymce_3_2_2_3.zip", "test/files/sourceforge.html", "test/files/tinymce_3_2_2.zip", "test/unit", "test/unit/tiny_mce_helper_test.rb", "test/helpers", "test/helpers/tiny_mce_helper_test.rb", "test/app_root", "test/app_root/config_bak", "test/app_root/config_bak/tiny_mce_options.yml", "test/app_root/config", "test/app_root/config/tiny_mce_options.yml", "test/test_helper.rb", "CHANGELOG.rdoc", "init.rb", "install.rb", "Rakefile", "README.rdoc", "uninstall.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.pluginaweek.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pluginaweek}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Adds helper methods for creating the TinyMCE initialization script in Rails}
  s.test_files = ["test/unit/tiny_mce_helper_test.rb", "test/helpers/tiny_mce_helper_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
