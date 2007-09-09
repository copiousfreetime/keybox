begin
    require 'rubygems'
    require 'keybox'
    require 'spec'
    require 'stringio'
    require 'tempfile'
rescue LoadError
    path = File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
    raise if $:.include? path
    $: << path
    retry
end