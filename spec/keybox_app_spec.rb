require 'tempfile'
require 'keybox'
require 'keybox/application/password_safe'

context "Keybox Password Safe Application" do
    setup do 

        @passphrase = "i love ruby"
        @testing_db = Tempfile.new("kps_db.yml")
        @testing_cfg = Tempfile.new("kps_cfg.yml")
        @path = @testing_db.path
        container = Keybox::Storage::Container.new(@passphrase, @testing_db.path)
        container << Keybox::HostAccountEntry.new("test account","localhost","guest", "rubyrocks")
        container << Keybox::URLAccountEntry.new("example site", "http://www.example.com", "rubyhacker")
        container.save
        container.save("/tmp/jjh-db.yml")

        @import_csv = Tempfile.new("keybox_import.csv")
        @import_csv.puts "title,hostname,username,password,additional_info"
        @import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"
        @import_csv.close

        @bad_import_csv = Tempfile.new("keybox_bad_header.csv")
        # missing a valid header
        @bad_import_csv.puts "title,host,username,password,additional_info"
        @bad_import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @bad_import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"

        @export_csv = Tempfile.new("keybox_export.csv")

    end

    teardown do
        @testing_db.unlink
        @testing_cfg.unlink
        @import_csv.unlink
        @bad_import_csv.unlink
        @export_csv.unlink

    end

    specify "nil argv should do nothing" do
        kps = Keybox::Application::PasswordSafe.new
        kps.error_message.should_be nil
    end

    specify "executing with no args should have output on stdout" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.size.should_be > 0
    end

    specify "general options get set correctly" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--debug", "--no-use-hash-for-url"])
        kps.merge_options
        kps.options.db_file.should_eql @testing_db.path
        kps.options.config_file.should_eql @testing_cfg.path
        kps.options.debug.should_eql true
        kps.options.use_password_hash_for_url.should_eql false
    end

    specify "more than one command options is an error" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "account", "--edit", "account"])
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.error_message.should_satisfy { |msg| msg =~ /Only one of/m }
            kps.stderr.string.should_satisfy { |msg| msg =~ /Only one of/m }
            se.status.should_eql 1
        end
    end

    specify "space separated words are okay for names" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "An Example"])
        prompted_values = [@passphrase, "An example"] + %w(example.com someuser apassword apassword noinfo yes)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 3
    end


    specify "invalid options set the error message, exit 1 and have output on stderr" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, 
                                                     "-c", @testing_cfg.path,
                                                     "--invalid-option"])
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
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
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            se.status.should_eql 0
            kps.stdout.string.length.should_be > 0
        end
    end

    specify "version has output on stdout and exits 0" do
        kps = Keybox::Application::PasswordSafe.new(["--ver"]) 
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            se.status.should_eql 0
            kps.stdout.string.length.should_be > 0
        end
    end
    
    specify "prompted for password twice to create database initially" do
        File.unlink(@testing_db.path)
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        stdin  = StringIO.new([@passphrase,@passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 0
        kps.stdout.string.should_satisfy { |msg| msg =~ /Creating initial database./m }
        kps.stdout.string.should_satisfy { |msg| msg =~ /Initial Password for/m }
    end

    specify "file can be opened with password" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        stdin  = StringIO.new(@passphrase + "\n")
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 2
    end

    specify "adding an entry to the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "example.com"])
        prompted_values = [@passphrase] + %w(example.com example.com someuser apassword apassword noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 3
    end

    specify "editing an entry in the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--edit", "localhost"])
        prompted_values = [@passphrase] + %w(yes example.com example.com someother anewpassword anewpassword someinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 2
        kps.db.find("someother")[0].additional_info.should_eql "someinfo"
    end

    specify "add a url entry to the database" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--use-hash-for-url", "--add", "http://www.example.com"])
        prompted_values = [@passphrase] + %w(www.example.com http://www.example.com someuser noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 3
    end

    specify "double prompting on failed password for entry to the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, 
                                                     "-c", @testing_cfg.path, 
                                                     "--add", "example.com"])
        prompted_values = [@passphrase, ""] + %w(example.com someuser 
                                                 apassword abadpassword 
                                                 abcdef abcdef noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 3
    end

    specify "able to delete an entry" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--delete", "example"])
        prompted_values = [@passphrase] + %w(Yes)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 1
        kps.stdout.string.should_satisfy { |msg| msg =~ /example' deleted/ }
    end

    specify "able to cancel deletion" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--delete", "example"])
        prompted_values = [@passphrase] + %w(No)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should_eql 2
        kps.stdout.string.should_satisfy { |msg| msg =~ /example' deleted/ }
    end

    specify "list all the entries" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--list"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /2./m }
    end

    specify "listing no entries found" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--list", "nothing"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /No matching records were found./ }
    end

    specify "showing no entries found" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--show", "nothing"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /No matching records were found./ }
    end


    specify "show all the entries" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--show"])
        stdin = StringIO.new([@passphrase, "", ""].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /2./m }
    end

    specify "changing master password works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--master-password"])
        stdin  = StringIO.new([@passphrase, "I really love ruby.", "I really love ruby."].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /New master password set/m }
    end

    specify "master password must be non-zero" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--master-password"])
        stdin  = StringIO.new([@passphrase, "", ""].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.stdout.string.should_satisfy { |msg| msg =~ /Passphrase is not strong enough./m }
            se.status.should_eql 1
        end
    end

    specify "importing from a valid csv file" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-i", @import_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /Imported \d* records from/m }
    end

    specify "Error message give on invalid imported csv" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-i", @bad_import_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.stdout.string.should_satisfy { |msg| msg =~ /Error: There must be a header on the CSV /m }
            se.status.should_eql 1
        end
    end

    specify "able to export to a csv" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-x", @export_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should_satisfy { |msg| msg =~ /Exported \d* records to/m }
    end

    specify "able to turn off color schemes" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","none"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.options.color_scheme.should_equal :none
    end

    specify "an invalid color scheme results in a no color scheme" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","dne"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.options.color_scheme.should_equal :none
    end

    specify "an incomplete color scheme results in an error message and then 'none' color scheme" do
        bad_color_scheme = { :bad => [:bold, :white, :on_magenta] }
        File.open("/tmp/test.color_scheme.yaml", "w+") { |f| f.write(bad_color_scheme.to_yaml) }
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","test"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run

        File.unlink("/tmp/test.color_scheme.yaml")
        kps.stdout.string.should_satisfy { |msg| msg =~ /It is missing the following items/m }
        kps.options.color_scheme.should_equal :none
    end
end
