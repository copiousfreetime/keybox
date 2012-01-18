# make sure our ./lib directory is added to the ruby search path
$: << File.expand_path(File.join(File.dirname(__FILE__),"lib"))

require 'rubygems'
require 'rubygems/package_task'
require 'rake/clean'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rake/contrib/sshpublisher'

require 'keybox'

load 'tasks/setup.rb'

