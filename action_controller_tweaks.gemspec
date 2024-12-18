# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

author_name = "PikachuEXE"
gem_name = "action_controller_tweaks"

require "#{gem_name}/version"

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = gem_name
  s.version       = ActionControllerTweaks.version
  s.summary       = "Some Tweaks for ActionController"
  s.description   = "ActionController is great, but could be better. Here are some tweaks for it."

  s.license       = "MIT"

  s.authors       = [author_name]
  s.email         = ["pikachuexe@gmail.com"]
  s.homepage      = "http://github.com/#{author_name}/#{gem_name}"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 7.0.0", "< 9.0.0"
  s.add_dependency "actionpack", ">= 7.0.0", "< 9.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake", ">= 10.0", "<= 14.0"
  s.add_development_dependency "appraisal", "~> 2.0", ">= 2.5.0"
  s.add_development_dependency "rspec-rails", ">= 5.1", "< 8"
  s.add_development_dependency "rspec-its", "~> 2.0"
  # rspec-rails needs activerecord...
  s.add_development_dependency "activerecord", ">= 4.0.0"
  s.add_development_dependency "sqlite3", ">= 1.3"
  s.add_development_dependency "database_cleaner", ">= 1.0"
  s.add_development_dependency "timecop", ">= 0.6"
  s.add_development_dependency "simplecov", ">= 0.21"
  s.add_development_dependency "simplecov-lcov", ">= 0.8"
  s.add_development_dependency "gem-release", ">= 0.7"
  # This is for rails < 4.1 on MRI 2.2 (and other later version I suppose)
  s.add_development_dependency "test-unit", ">= 3.0.0"

  s.required_ruby_version = ">= 2.7.0"

  s.required_rubygems_version = ">= 1.4.0"
end
