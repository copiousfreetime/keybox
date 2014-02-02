if RUBY_VERSION >= '1.9.2' then
  require 'simplecov'
  puts "Using coverage!"
  SimpleCov.start if ENV['COVERAGE']
end

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'keybox'
require 'stringio'
require 'tempfile'

# termios cannot be used during testing
begin
  require 'termios'
  raise "ERROR!!!! termios library found.  It is not possible to run keybox tests with the termios library at this time."
  exit 2
rescue LoadError
end
