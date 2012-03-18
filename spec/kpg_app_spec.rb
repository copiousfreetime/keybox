require 'spec_helper'
require 'keybox/application/password_generator'

describe "Keybox Password Generator Application" do

    it "nil argv should do nothing" do
        kpg = Keybox::Application::PasswordGenerator.new(nil)
        kpg.error_message.should == nil
    end

    it "invalid options set the error message, exit 1 and have output on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--invalid-option"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should =~ /Try.*--help/m
            kpg.stderr.string.should =~ /Try.*--help/m
            se.status.should == 1
        end
    end

    it "can set the algorithm" do
        kpg = Keybox::Application::PasswordGenerator.new(["--alg", "pron"])
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run
        kpg.options.algorithm.should == :pronounceable
    end
    
    it "can it the number of passwords created " do
        kpg = Keybox::Application::PasswordGenerator.new(["--num", "4"])
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run
        kpg.options.number_to_generate.should be == 4
        kpg.stdout.string.split(/\s+/).should have(4).items
    end

    it "help has output on stdout and exits 0" do
        kpg = Keybox::Application::PasswordGenerator.new(["--h"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            se.status.should be == 0
            kpg.stdout.string.length.should > 0
        end
        kpg.stdout.string.should =~ /--help/m
    end

    it "version has output on stdout and exits 0" do
        kpg = Keybox::Application::PasswordGenerator.new(["--version"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            se.status.should == 0
        end
        kpg.stdout.string.should  =~ /version 1/m
    end

    it "minimum length can be set and all generated passwords will have length >= minimum length" do
        kpg = Keybox::Application::PasswordGenerator.new(["--min", "4"]) 
        kpg.set_io(StringIO.new,StringIO.new)
        kpg.run

        kpg.options.min_length.should be == 4
        kpg.stdout.string.split("\n").each do |pass|
            pass.length.should >= kpg.options.min_length 
        end
    end

    it "maximum length can be set and all generated passwords will have length <= maximum length" do
        kpg = Keybox::Application::PasswordGenerator.new(["--max", "4", "--min", "3"]) 
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run

        kpg.options.max_length.should be == 4
        kpg.stdout.string.split("\n").each do |pass|
            pass.length.should <= 4 
        end
    end

    it "setting an invalid required symbol set exits 1 and outputs data on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--req","bunk"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should =~ /Try.*--help/m
            kpg.stderr.string.should =~ /Try.*--help/m
            se.status.should == 1
        end
 
    end

    it "setting an invalid use symbol set exits 1 and outputs data on stderr" do
        kpg = Keybox::Application::PasswordGenerator.new(["--use","bunk"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        begin
            kpg.run
        rescue SystemExit => se
            kpg.error_message.should =~ /Try.*--help/m
            kpg.stderr.string.should =~ /Try.*--help/m 
            se.status.should == 1
        end
 
    end

    it "setting an valid use symbol works" do
        kpg = Keybox::Application::PasswordGenerator.new(["--use","l"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run
        kpg.options.use_symbols.should be_include(Keybox::SymbolSet::LOWER_ASCII)
        kpg.stdout.string.split(/\s+/).size.should == 6
    end

    it "setting an valid required symbol works" do
        kpg = Keybox::Application::PasswordGenerator.new(["--req","l"])
        kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
        kpg.run
        kpg.options.require_symbols.should be_include(Keybox::SymbolSet::LOWER_ASCII)
        kpg.stdout.string.split(/\s+/).size.should == 6
    end
end

