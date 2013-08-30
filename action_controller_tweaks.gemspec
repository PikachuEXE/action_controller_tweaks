# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

author_name = 'PikachuEXE'
gem_name = 'action_controller_tweaks'

require "#{gem_name}/version"

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = gem_name
  s.version       = ActionControllerTweaks::VERSION
  s.summary       = 'Some Tweaks for ActionController'
  s.description   = 'ActionController is great, but could be better. Here are some tweaks for it.'

  s.license       = 'MIT'

  s.authors       = [author_name]
  s.email         = ['pikachuexe@gmail.com']
  s.homepage      = "http://github.com/#{author_name}/#{gem_name}"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 3.2.0', '< 5.0.0'
  s.add_dependency 'actionpack', '>= 3.2.0', '< 5.0.0'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'activerecord', '>= 3.2.0', '< 5.0.0' # rspec-rails needs activerecord...
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'coveralls'
end
