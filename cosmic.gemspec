# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cosmic}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Dudziak"]
  s.date = %q{2012-03-05}
  s.default_executable = %q{cosmic}
  s.description = %q{Library/tool for automating deployments}
  s.email = %q{thomas@ning.com}
  s.executables = ["cosmic"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.md"
  ]
  s.files = [
    "LICENSE.txt",
     "README.md",
     "Rakefile",
     "VERSION",
     "bin/cosmic",
     "lib/cosmic.rb",
     "lib/cosmic/chef.rb",
     "lib/cosmic/cosmic.rb",
     "lib/cosmic/execute.rb",
     "lib/cosmic/f5.rb",
     "lib/cosmic/galaxy.rb",
     "lib/cosmic/irc.rb",
     "lib/cosmic/jira.rb",
     "lib/cosmic/jmx.rb",
     "lib/cosmic/mail.rb",
     "lib/cosmic/nagios.rb",
     "lib/cosmic/patches.rb",
     "lib/cosmic/plugin.rb",
     "lib/cosmic/ssh.rb",
     "lib/cosmic/taskgroup.rb"
  ]
  s.homepage = %q{https://github.com/ning/cosmic}
  s.licenses = ["ASL2"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Library/tool for automating deployments}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6.9"])
      s.add_runtime_dependency(%q<net-ldap>, ["~> 0.2.2"])
    else
      s.add_dependency(%q<yard>, ["~> 0.6.1"])
      s.add_dependency(%q<highline>, ["~> 1.6.9"])
      s.add_dependency(%q<net-ldap>, ["~> 0.2.2"])
    end
  else
    s.add_dependency(%q<yard>, ["~> 0.6.1"])
    s.add_dependency(%q<highline>, ["~> 1.6.9"])
    s.add_dependency(%q<net-ldap>, ["~> 0.2.2"])
  end
end

