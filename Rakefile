# make sure our ./lib directory is added to the ruby search path
$: << File.expand_path(File.join(File.dirname(__FILE__),"lib"))

require 'ostruct'
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'keybox'

# load all the extra tasks for the project
FileList["tasks/*.rake"].each { |tasklib| import tasklib }

task :default => 'test:default'

#-----------------------------------------------------------------------
# update the top level clobber task to depend on all possible sub-level
# tasks that have a name like ':clobber'  in other namespaces
#-----------------------------------------------------------------------
Rake.application.tasks.each do |t|
    if t.name =~ /:clobber/ then
        task :clobber => [t.name]
    end
end
