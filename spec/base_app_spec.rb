require 'spec_helper'
require 'keybox/application/base'

describe "Keybox Base Application" do

  it "nil argv does nothing" do
    kba = Keybox::Application::Base.new(nil)
    kba.error_message.must_be_nil
  end

  it "executing with no args sends output on stdout" do
    kba = Keybox::Application::Base.new(nil)
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    kba.run
    kba.stdout.string.size.must_be( :>, 0 )
  end

  it "invalid options set the error message, exit 1 and have output on stderr" do
    kba = Keybox::Application::Base.new(["--invalid-option"])
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      kba.error_message.must_match( /Try.*--help/m )
      kba.stderr.string.must_match( /Try.*--help/m )
      kba.stdout.string.size.must_equal 0
      se.status.must_equal 1
    end
  end

  it "help has output on stdout and exits 0" do
    kba = Keybox::Application::Base.new(["--h"]) 
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      se.status.must_equal 0
      kba.stdout.string.length.must_be( :>, 0 )
    end
  end

  it "version has output on stdout and exits 0" do
    kba = Keybox::Application::Base.new(["--ver"]) 
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      se.status.must_equal 0
      kba.stdout.string.length.must_be( :>, 0 )
    end
  end
end

