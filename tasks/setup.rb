# Try to laod the given _library_ using the built-in require, but do not
# raise a LoadError if unsuccessful. Returns +true+ if the _library_ was
# successfully loaded; returns +false+ otherwise.

def try_require( lib )
  require lib
  true
rescue LoadError
  false
end

# setup global constants so the task libs can make decisions based upon the availability
# of other libraries.

%w(heel webby).each do |lib|
  Object.instance_eval { const_set "HAVE_#{lib.upcase}", try_require(lib) }
end

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
