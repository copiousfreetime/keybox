require 'tempfile'
require 'keybox'
require 'keybox/application/password_safe'

describe "Keybox Password Safe Application" do
    before(:each) do 

        @passphrase = "i love ruby"
        @testing_db = Tempfile.new("kps_db.yml")
        @testing_cfg = Tempfile.new("kps_cfg.yml")
        @path = @testing_db.path
        container = Keybox::Storage::Container.new(@passphrase, @testing_db.path)
        container << Keybox::HostAccountEntry.new("test account","localhost","guest", "rubyrocks")
        container << Keybox::URLAccountEntry.new("example site", "http://www.example.com", "rubyhacker")
        container.save

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

    after(:each) do
        @testing_db.unlink
        @testing_cfg.unlink
        @import_csv.unlink
        @bad_import_csv.unlink
        @export_csv.unlink

    end

    it "nil argv should do nothing" do
        kps = Keybox::Application::PasswordSafe.new
        kps.error_message.should == nil
    end

    it "executing with no args should have output on stdout" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.size.should > 0
    end

    it "general options get set correctly" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--debug", "--no-use-hash-for-url"])
        kps.merge_options
        kps.options.db_file.should == @testing_db.path
        kps.options.config_file.should == @testing_cfg.path
        kps.options.debug.should == true
        kps.options.use_password_hash_for_url.should == false
    end

    it "more than one command options is an error" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "account", "--edit", "account"])
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.error_message.should =~ /Only one of/m 
            kps.stderr.string.should =~ /Only one of/m
            se.status.should == 1
        end
    end

    it "space separated words are okay for names" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "An Example"])
        prompted_values = [@passphrase, "An example"] + %w(example.com someuser apassword apassword noinfo yes)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 3
    end


    it "invalid options set the error message, exit 1 and have output on stderr" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, 
                                                     "-c", @testing_cfg.path,
                                                     "--invalid-option"])
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.error_message.should =~ /Try.*--help/m 
            kps.stderr.string.should =~ /Try.*--help/m 
            kps.stdout.string.size.should == 0
            se.status.should == 1
        end
    end

    it "help has output on stdout and exits 0" do
        kps = Keybox::Application::PasswordSafe.new(["--h"]) 
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            se.status.should == 0
            kps.stdout.string.length.should > 0
        end
    end

    it "version has output on stdout and exits 0" do
        kps = Keybox::Application::PasswordSafe.new(["--ver"]) 
        kps.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            se.status.should == 0
            kps.stdout.string.length.should > 0
        end
    end
    
    it "prompted for password twice to create database initially" do
        File.unlink(@testing_db.path)
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        stdin  = StringIO.new([@passphrase,@passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 0
        kps.stdout.string.should =~ /Creating initial database./m 
        kps.stdout.string.should =~ /Initial Password for/m 
    end

    it "file can be opened with password" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path])
        stdin  = StringIO.new(@passphrase + "\n")
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 2
    end

    it "adding an entry to the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--add", "example.com"])
        prompted_values = [@passphrase] + %w(example.com example.com someuser apassword apassword noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 3
    end

    it "editing an entry in the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--edit", "localhost"])
        prompted_values = [@passphrase] + %w(yes example.com example.com someother anewpassword anewpassword someinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 2
        kps.db.find("someother")[0].additional_info.should == "someinfo"
    end

    it "add a url entry to the database" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--use-hash-for-url", "--add", "http://www.example.com"])
        prompted_values = [@passphrase] + %w(www.example.com http://www.example.com someuser noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 3
    end

    it "double prompting on failed password for entry to the database works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, 
                                                     "-c", @testing_cfg.path, 
                                                     "--add", "example.com"])
        prompted_values = [@passphrase, ""] + %w(example.com someuser apassword abadpassword abcdef abcdef noinfo yes)
        stdin  = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 3
    end

    it "able to delete an entry" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--delete", "example"])
        prompted_values = [@passphrase] + %w(Yes)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 1
        kps.stdout.string.should =~ /example' deleted/ 
    end

    it "able to cancel deletion" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--delete", "example"])
        prompted_values = [@passphrase] + %w(No)
        stdin = StringIO.new(prompted_values.join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.db.records.size.should == 2
        kps.stdout.string.should =~ /example' deleted/ 
    end

    it "list all the entries" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--list"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /2./m 
    end

    it "listing no entries found" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--list", "nothing"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /No matching records were found./ 
    end

    it "showing no entries found" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--show", "nothing"])
        stdin = StringIO.new(@passphrase)
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /No matching records were found./ 
    end


    it "show all the entries" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--show"])
        stdin = StringIO.new([@passphrase, "", ""].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /2./m 
    end

    it "changing master password works" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--master-password"])
        stdin  = StringIO.new([@passphrase, "I really love ruby.", "I really love ruby."].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /New master password set/m 
    end

    it "master password must be non-zero" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path, "--master-password"])
        stdin  = StringIO.new([@passphrase, "", ""].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.stdout.string.should =~ /Passphrase is not strong enough./m 
            se.status.should == 1
        end
    end

    it "importing from a valid csv file" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-i", @import_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should =~ /Imported \d* records from/m 
    end

    it "Error message give on invalid imported csv" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-i", @bad_import_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        begin
            kps.run
        rescue SystemExit => se
            kps.stdout.string.should =~ /Error: There must be a header on the CSV /m 
            se.status.should == 1
        end
    end

    it "able to export to a csv" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"-x", @export_csv.path])
        stdin  = StringIO.new([@passphrase, @passphrase].join("\n"))
        kps.set_io(stdin,StringIO.new,StringIO.new)
        kps.run
        kps.stdout.string.should  =~ /Exported \d* records to/m 
    end

    it "able to turn off color schemes" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","none"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.options.color_scheme.should == :none
    end

    it "an invalid color scheme results in a no color scheme" do
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","dne"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run
        kps.options.color_scheme.should == :none
    end

    it "an incomplete color scheme results in an error message and then 'none' color scheme" do
        bad_color_scheme = { :bad => [:bold, :white, :on_magenta] }
        File.open("/tmp/test.color_scheme.yaml", "w+") { |f| f.write(bad_color_scheme.to_yaml) }
        kps = Keybox::Application::PasswordSafe.new(["-f", @testing_db.path, "-c", @testing_cfg.path,"--color","test"])
        kps.set_io(StringIO.new(@passphrase),StringIO.new,StringIO.new)
        kps.run

        File.unlink("/tmp/test.color_scheme.yaml")
        kps.stdout.string.should =~ /It is missing the following items/m 
        kps.options.color_scheme.should == :none
    end
end
