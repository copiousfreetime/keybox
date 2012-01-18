begin
  USING_BONES_VERSION = '3.7.1'
  require 'bones'
rescue LoadError
  load 'tasks/contribute.rake'
  Rake.application.invoke_task( :help )
end

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

$: << 'lib'
require 'keybox/version'

Bones {
  name    'keybox'
  authors 'Jeremy Hinegardner'
  email   'jeremy@hinegardner.org'
  url     'http://keybox.rubyforge.org'
  version  Keybox::VERSION

  ruby_ops      %w[ -W0 -rubygems ]
  readme_file   'README'
  ignore_file   '.gitignore'
  history_file  'CHANGES'

  spec.opts << "--color" << "--format documentation"

  summary     'Secure pasword storage.'
  description <<_
A set of command line applications and ruby libraries for
secure password storage and password generation.
_

  depend_on 'highline', '~> 1.6.2'

  depend_on 'bones'       , "~> #{USING_BONES_VERSION}", :development => true
  depend_on 'bones-rspec' , "~> 2.0.1"  , :development  => true
  depend_on 'rspec'       , "~> 2.8.0"  , :development  => true
  depend_on 'rdoc'        , "~> 3.12"   , :development  => true
  depend_on 'rake'        , "~> 0.9.2.2", :development  => true
}

::Bones.config.gem._spec.dependencies.delete_if do |d|
  d.name == 'bones' and d.requirement.to_s =~ /^>=/
end
