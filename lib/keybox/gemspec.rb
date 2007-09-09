require 'rubygems'
require 'keybox/specification'
require 'keybox/version'
require 'rake'

module Keybox
    SPEC = Keybox::Specification.new do |spec|
                spec.name               = "keybox"
                spec.version            = Keybox::VERSION
                spec.rubyforge_project  = "keybox"
                spec.author             = "Jeremy Hinegardner"
                spec.email              = "jeremy@hinegardner.org"
                spec.homepage           = "http://keybox.rubyforge.org"

                spec.summary            = "Secure pasword storage."
                spec.description        = <<-DESC
                A set of command line applications and ruby libraries for
                secure password storage and password generation.
                DESC

                spec.extra_rdoc_files   = FileList["CHANGES", "COPYING", "README"]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*.rb"]
                spec.executable         = Dir.entries("bin").delete_if { |f| f =~ /\A\./ }
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb", "resources/**/*", "data/**/*"]

                spec.add_dependency("highline", ">= 1.4.0")

                spec.required_ruby_version  = ">= 1.8.5"

                spec.platform = Gem::Platform::RUBY

                spec.remote_user        = "jjh"
                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = ""
                spec.local_coverage_dir = "doc/coverage"

                spec.remote_site_dir    = "#{spec.name}/"
                
                spec.post_install_message = "\e[1m\e[31m\e[40mTry `keybox --help` for more information\e[0m"
                

           end
end


