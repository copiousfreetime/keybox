require 'spec_helper'
require 'keybox/application/password_generator'

describe "Keybox Password Generator Application" do

  it "nil argv does nothing" do
    kpg = Keybox::Application::PasswordGenerator.new(nil)
    kpg.error_message.must_be_nil
  end

  it "invalid options set the error message, exit 1 and have output on stderr" do
    kpg = Keybox::Application::PasswordGenerator.new(["--invalid-option"])
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kpg.run
    rescue SystemExit => se
      kpg.error_message.must_match( /Try.*--help/m )
      kpg.stderr.string.must_match( /Try.*--help/m )
      se.status.must_equal 1
    end
  end

  it "can set the algorithm" do
    kpg = Keybox::Application::PasswordGenerator.new(["--alg", "pron"])
    kpg.set_io(StringIO.new,StringIO.new)
    kpg.run
    kpg.options.algorithm.must_equal :pronounceable
  end

  it "can it the number of passwords created " do
    kpg = Keybox::Application::PasswordGenerator.new(["--num", "4"])
    kpg.set_io(StringIO.new,StringIO.new)
    kpg.run
    kpg.options.number_to_generate.must_equal 4
    kpg.stdout.string.split(/\s+/).size.must_equal 4
  end

  it "help has output on stdout and exits 0" do
    kpg = Keybox::Application::PasswordGenerator.new(["--h"]) 
    kpg.set_io(StringIO.new,StringIO.new)
    begin
      kpg.run
    rescue SystemExit => se
      se.status.must_equal 0
      kpg.stdout.string.length.must_be( :>, 0 )
    end
    kpg.stdout.string.must_match( /--help/m )
  end

  it "version has output on stdout and exits 0" do
    kpg = Keybox::Application::PasswordGenerator.new(["--version"]) 
    kpg.set_io(StringIO.new,StringIO.new)
    begin
      kpg.run
    rescue SystemExit => se
      se.status.must_equal 0
    end
    kpg.stdout.string.must_match( /version 1/m )
  end

  it "minimum length can be set and all generated passwords will have length >= minimum length" do
    kpg = Keybox::Application::PasswordGenerator.new(["--min", "4"]) 
    kpg.set_io(StringIO.new,StringIO.new)
    kpg.run

    kpg.options.min_length.must_equal 4
    kpg.stdout.string.split("\n").each do |pass|
      pass.length.must_be( :>=, kpg.options.min_length )
    end
  end

  it "maximum length can be set and all generated passwords will have length <= maximum length" do
    kpg = Keybox::Application::PasswordGenerator.new(["--max", "4", "--min", "3"]) 
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    kpg.run

    kpg.options.max_length.must_equal 4
    kpg.stdout.string.split("\n").each do |pass|
      pass.length.must_be( :<=, 4 )
    end
  end

  it "setting an invalid required symbol set exits 1 and outputs data on stderr" do
    kpg = Keybox::Application::PasswordGenerator.new(["--req","bunk"])
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kpg.run
    rescue SystemExit => se
      kpg.error_message.must_match( /Try.*--help/m )
      kpg.stderr.string.must_match(/Try.*--help/m)
      se.status.must_equal 1
    end

  end

  it "setting an invalid use symbol set exits 1 and outputs data on stderr" do
    kpg = Keybox::Application::PasswordGenerator.new(["--use","bunk"])
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    begin
      kpg.run
    rescue SystemExit => se
      kpg.error_message.must_match( /Try.*--help/m )
      kpg.stderr.string.must_match( /Try.*--help/m )
      se.status.must_equal 1
    end

  end

  it "setting an valid use symbol works" do
    kpg = Keybox::Application::PasswordGenerator.new(["--use","l"])
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    kpg.run
    kpg.options.use_symbols.must_include(Keybox::SymbolSet::LOWER_ASCII)
    kpg.stdout.string.split(/\s+/).size.must_equal 6
  end

  it "setting an valid required symbol works" do
    kpg = Keybox::Application::PasswordGenerator.new(["--req","l"])
    kpg.set_io(StringIO.new,StringIO.new,StringIO.new)
    kpg.run
    kpg.options.require_symbols.must_include(Keybox::SymbolSet::LOWER_ASCII)
    kpg.stdout.string.split(/\s+/).size.must_equal 6
  end
end

