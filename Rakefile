# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "keybox"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.exclude_from_manifest = %r/\.(git|DS_Store)|^(doc|coverage|pkg|tmp|website|Gemfile(\.lock)?)|^[^\/]+\.gemspec|\.(swp|jar|bundle|so|rvmrc)$|~$/
This.ruby_gemspec do |spec|
  spec.licenses = %w[MIT]
  spec.add_runtime_dependency( 'highline', '~> 1.6' )

  # The Development Dependencies
  spec.add_development_dependency( 'rake'  , '~> 10.1')
  spec.add_development_dependency( 'minitest' , '~> 5.2'  )
  spec.add_development_dependency( 'rdoc'  , '~> 4.1'   )

  # have to move to 1.9.3 and up now
  spec.required_ruby_version = ">= 1.9.3"
end



load 'tasks/default.rake'
