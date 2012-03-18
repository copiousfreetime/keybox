require 'spec_helper'

describe "Keybox Base Application" do

  it "nil argv should do nothing" do
    kba = Keybox::Application::Base.new(nil)
    kba.error_message.should == nil
  end

  it "executing with no args should have output on stdout" do
    kba = Keybox::Application::Base.new(nil)
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    kba.run
    kba.stdout.string.size.should be > 0
  end

  it "invalid options set the error message, exit 1 and have output on stderr" do
    kba = Keybox::Application::Base.new(["--invalid-option"])
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      kba.error_message.should =~ /Try.*--help/m 
      kba.stderr.string.should =~ /Try.*--help/m 
      kba.stdout.string.size.should be == 0
      se.status.should be == 1
    end
  end

  it "help has output on stdout and exits 0" do
    kba = Keybox::Application::Base.new(["--h"]) 
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      se.status.should be == 0
      kba.stdout.string.length.should > 0
    end
  end

  it "version has output on stdout and exits 0" do
    kba = Keybox::Application::Base.new(["--ver"]) 
    kba.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kba.run
    rescue SystemExit => se
      se.status.should be == 0
      kba.stdout.string.length.should > 0
    end
  end
end

