require 'spec_helper'

describe 'a storage record entry' do
    before(:each) do
        @data_fields = %w(title username password url additional_data)
    end
    it 'has a creation date set on instantiation' do
        e = Keybox::Storage::Record.new
        e.creation_time.should be_instance_of(Time)
    end

    it "assigning to a non-existant field creates the appropriate member " do
        e = Keybox::Storage::Record.new
        e.junk = "junk"
        e.junk.should == "junk"
    end

    it 'default values for non-existant fields is nil' do 
        e = Keybox::Storage::Record.new
        @data_fields.each do |f|
            e.send(f).should == nil
        end
    end

    it "assigning to a field makes the modification time > creation time" do
        e = Keybox::Storage::Record.new
        sleep 1
        e.testing = "testing"
        e.modification_time.should be > e.creation_time 
        e.last_access_time.should == e.modification_time
    end

    it "sets modified to be true when a key is changed" do
         e = Keybox::Storage::Record.new
         e.should_not be_modified
         e.thing = "test"
         e.should be_modified
    end

    it "reading a field after assignment the access time > modification time " do
        e = Keybox::Storage::Record.new
        e.testing = "testing"
        sleep 1
        e.testing
        e.last_access_time.should be > e.creation_time 
        e.last_access_time.should be > e.modification_time
    end

    it "assigning to a modification, creation or acces_time should raise and exception " do
        e = Keybox::Storage::Record.new
        lambda {e.modification_time = Time.now}.should raise_error(NoMethodError)
    end

    it "assiging multiple items should raise an argument exception" do
        e = Keybox::Storage::Record.new
        lambda {e.send(:stuff=,1,2)}.should raise_error(ArgumentError)
    end

    it "calling a method with arguments should raise exception" do
        e = Keybox::Storage::Record.new
        lambda {e.stuff(1,2)}.should raise_error(NoMethodError)
    end

    it "comparison between records is valid" do
        e = Keybox::Storage::Record.new
        f = e.dup
        e.should be == e.uuid
        e.should be == f
    end

    it "can be round-tripped to YAML multiple times" do
        record = Keybox::Storage::Record.new
        restored = YAML.load(record.to_yaml)
        YAML.load(restored.to_yaml).should == record
    end
end
