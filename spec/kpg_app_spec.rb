require 'keybox'
require 'keybox/application/password_generator'

context "Keybox Password Generator Application" do
    setup do
    end

    specify "nil argv should do nothing" do
        kpg = Keybox::Application::PasswordGenerator.new(nil)
        kpg.error_message.should_be nil
    end

    specify "invalid options set the error message, exit 1 and have output on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--invalid-option"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kpg.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            se.status.should == 1
        end
    end

    specify "can set the algorithm" do
        kpg = Keybox::Application::PasswordGenerator.new(["--alg", "pron"])
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run
        kpg.options.algorithm.should == :pronounceable
    end
    
    specify "can specify the number of passwords created " do
        kpg = Keybox::Application::PasswordGenerator.new(["--num", "4"])
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run
        kpg.options.number_to_generate.should_eql 4
        kpg.stdout.string.split(/\s+/).size.should == 4
    end

    specify "help has output on stdout and exits 0" do
        kpg = Keybox::Application::PasswordGenerator.new(["--h"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            se.status.should_eql 0
            kpg.stdout.string.length.should_be > 0
        end
        kpg.stdout.string.should_satisfy { |msg| msg =~ /--help/m }
    end

    specify "version has output on stdout and exits 0" do
        kpg = Keybox::Application::PasswordGenerator.new(["--version"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            se.status.should_eql 0
        end
        kpg.stdout.string.should_satisfy { |msg| msg =~ /version 1/m }
    end

    specify "minimum length can be set and all generated passwords will have length >= minimum length" do
        kpg = Keybox::Application::PasswordGenerator.new(["--min", "4"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run

        kpg.options.min_length.should_eql 4
        kpg.stdout.string.split("\n").each do |pass|
            pass.length.should_satisfy { |s| s >= kpg.options.min_length }
        end
    end

    specify "maximum length can be set and all generated passwords will have length <= maximum length" do
        kpg = Keybox::Application::PasswordGenerator.new(["--max", "4", "--min", "3"]) 
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run

        kpg.options.max_length.should_eql 4
        kpg.stdout.string.split("\n").each do |pass|
            pass.length.should_satisfy { |s| s <= 4 }
        end
    end

    specify "setting an invalid required symbol set exits 1 and outputs data on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--req","bunk"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kpg.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            se.status.should == 1
        end
 
    end

    specify "setting an invalid use symbol set exits 1 and outputs data on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--use","bunk"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should_satisfy { |msg| msg =~ /Try.*--help/m }
            kpg.stderr.string.should_satisfy { |msg| msg =~ /Try.*--help/m }
            se.status.should == 1
        end
 
    end

    specify "setting an valid use symbol works" do
        kpg = Keybox::Application::PasswordGenerator.new(["--use","l"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run
        kpg.options.use_symbols.should_include Keybox::SymbolSet::LOWER_ASCII
        kpg.stdout.string.split(/\s+/).size.should == 6
    end

    specify "setting an valid required symbol works" do
        kpg = Keybox::Application::PasswordGenerator.new(["--req","l"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run
        kpg.options.require_symbols.should_include Keybox::SymbolSet::LOWER_ASCII
        kpg.stdout.string.split(/\s+/).size.should == 6
    end





end

