require 'tempfile'
require 'keybox'
require 'keybox/application/password_safe'

context "Keybox Password Safe Application" do
    setup do 
        @passphrase = "i love ruby"
        @testing_db = Tempfile.new("kps_db.yml")
        container = Keybox::Storage::Container.new(@passphrase, @testing_db.path)
        container << Keybox::HostAccountEntry.new("test account","localhost","guest", "rubyrocks")
        container << Keybox::URLAccountEntry.new("the times", "http://www.nytimes.com", "rubyhacker")
        container.save
    end

    teardown do
        @testing_db.unlink
    end

    specify "nil argv should do nothing" do
        kps = Keybox::Application::PasswordSafe.new(nil)
        kps.error_message.should_be nil
    end

    specify "executing with no args should have output on stdout" do
        kps = Keybox::Application::PasswordSafe.new(nil)
        kps.stdout = StringIO.new
        kps.stdin  = StringIO.new(@passphrase)
        kps.run
        kps.stdout.string.size.should_be > 0
    end

    specify "general options get set correctly" do
        kps = Keybox::Application::PasswordSafe.new(%w(--file /tmp/kps_db.yaml --config /tmp/kps_cfg.yaml --debug --no-use-hash-for-url))
        kps.options.db_file.should_eql "/tmp/kps_db.yaml"
        kps.options.config_file.should_eql "/tmp/kps_cfg.yaml"
        kps.options.debug.should_eql true
        kps.options.use_password_hash_for_url.should_eql false
    end

    specify "more than one command options is an error" do
        kps = Keybox::Application::PasswordSafe.new(%w(--add account --edit account ))
        kps.stderr = StringIO.new
        kps.stdout = StringIO.new
        begin
            kps.run
        rescue SystemExit => se
            kps.error_message.should_satisfy { |msg| msg =~ /Only one of/m }
            kps.stderr.string.should_satisfy { |msg| msg =~ /Only one of/m }
            se.status.should_eql 1
        end
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

    specify "version has output on stdout and exits 0" do
        kps = Keybox::Application::PasswordSafe.new(["--ver"]) 
        kps.stdout = StringIO.new
        begin
            kps.run
        rescue SystemExit => se
            se.status.should_eql 0
            kps.stdout.string.length.should_be > 0
        end
    end

    specify "file can be opened with password" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path])
        kps.stdout = StringIO.new
        kps.stdin  = StringIO.new(@passphrase + "\n")
        kps.run
        kps.db.records.size.should_eql 2
    end

end

