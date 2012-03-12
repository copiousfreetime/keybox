# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "keybox/version"

Gem::Specification.new do |s|
  s.name        = "keybox"
  s.version     = Keybox::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeremy Hinegardner"]
  s.email       = ["jeremy@hinegardner.org"]
  s.homepage    = "http://keybox.rubyforge.org"
  s.summary     = %q{Secure pasword storage.}
  s.description = <<_
A set of command line applications and ruby libraries for
secure password storage and password generation.
_

  s.rubyforge_project = "keybox"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "rdoc"

  s.add_dependency 'highline', '~> 1.6.2'
end
