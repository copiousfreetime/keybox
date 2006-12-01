require 'keybox'
require 'keybox/application/password_safe'

context "Keybox Password Safe Application" do

    specify "nil argv should do nothing" do
        kps = Keybox::Application::PasswordSafe.new(nil)
        kps.error_message.should_be nil
    end

    specify "executing with no args should have output on stdout" do
        kps = Keybox::Application::PasswordSafe.new(nil)
        kps.stdout = StringIO.new
        kps.run
        kps.stdout.string.size.should_be > 0
    end


    specify "invalid options set the error message, exit 1 and have output on stderr" do
        kps = Keybox::Application::PasswordSafe.new(["--invalid-option"])
        kps.stderr = StringIO.new
        kps.stdout = StringIO.new
        begin
            kps.run
        rescue SystemExit => se
            kps.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kps.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kps.stdout.string.size.should_eql 0
            se.status.should == 1
        end
    end

    specify "help has output on stdout and exits 0" do
        kps = Keybox::Application::PasswordSafe.new(["--h"]) 
        kps.stdout = StringIO.new
        begin
            kps.run
        rescue SystemExit => se
            se.status.should_eql 0
            kps.stdout.string.length.should_be > 0
        end
    end
end

