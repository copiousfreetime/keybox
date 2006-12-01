require 'keybox'
require 'keybox/application/base'

context "Keybox Base Application" do

    specify "nil argv should do nothing" do
        kpg = Keybox::Application::Base.new(nil)
        kpg.error_message.should_be nil
    end

    specify "executing with no args should have output on stdout" do
        kpg = Keybox::Application::Base.new(nil)
        kpg.stdout = StringIO.new
        kpg.run
        kpg.stdout.string.size.should_be > 0
    end


    specify "invalid options set the error message, exit 1 and have output on stderr" do
        kpg = Keybox::Application::Base.new(["--invalid-option"])
        kpg.stderr = StringIO.new
        kpg.stdout = StringIO.new
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kpg.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kpg.stdout.string.size.should_eql 0
            se.status.should == 1
        end
    end

    specify "help has output on stdout and exits 0" do
        kpg = Keybox::Application::Base.new(["--h"]) 
        kpg.stdout = StringIO.new
        begin
            kpg.run
        rescue SystemExit => se
            se.status.should_eql 0
            kpg.stdout.string.length.should_be > 0
        end
    end
end

