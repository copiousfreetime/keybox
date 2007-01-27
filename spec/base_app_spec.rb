require 'keybox'
require 'keybox/application/base'

context "Keybox Base Application" do

    specify "nil argv should do nothing" do
        kba = Keybox::Application::Base.new(nil)
        kba.error_message.should_be nil
    end

    specify "executing with no args should have output on stdout" do
        kba = Keybox::Application::Base.new(nil)
        kba.set_io(StringIO.new,StringIO.new,StringIO.new)
        kba.run
        kba.stdout.string.size.should_be > 0
    end


    specify "invalid options set the error message, exit 1 and have output on stderr" do
        kba = Keybox::Application::Base.new(["--invalid-option"])
        kba.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kba.run
        rescue SystemExit => se
            kba.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kba.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kba.stdout.string.size.should_eql 0
            se.status.should == 1
        end
    end

    specify "help has output on stdout and exits 0" do
        kba = Keybox::Application::Base.new(["--h"]) 
        kba.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kba.run
        rescue SystemExit => se
            se.status.should_eql 0
            kba.stdout.string.length.should_be > 0
        end
    end

    specify "version has output on stdout and exits 0" do
        kba = Keybox::Application::Base.new(["--ver"]) 
        kba.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kba.run
        rescue SystemExit => se
            se.status.should_eql 0
            kba.stdout.string.length.should_be > 0
        end
    end
 
end

