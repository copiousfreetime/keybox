begin
    require 'rubygems'
    require 'keybox'
    require 'rspec'
    require 'stringio'
    require 'tempfile'
    
    # termios cannot be used during testing
    begin
        require 'termios'
        raise "ERROR!!!! termios library found.  It is not possible to run keybox tests with the termios library at this time."
        exit 2
    rescue LoadError
    end
    
rescue LoadError
    path = File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
    raise if $:.include? path
    $: << path
    retry
end