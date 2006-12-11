require 'keybox/storage'

context 'a storage record entry' do
    setup do
        @data_fields = %w(title username password url additional_data)
    end
    specify 'has a creation date set on instantiation' do
        e = Keybox::Storage::Record.new
        e.creation_time.should_be_instance_of(Time)
    end

    specify "assigning to a non-existant field creates the appropriate member " do
        e = Keybox::Storage::Record.new
        e.junk = "junk"
        e.junk.should == "junk"
    end

    specify 'default values for non-existant fields is nil' do 
        e = Keybox::Storage::Record.new
        @data_fields.each do |f|
            e.send(f).should_be  nil
        end
    end

    specify "assigning to a field makes the modification time > creation time" do
        e = Keybox::Storage::Record.new
        sleep 1
        e.testing = "testing"
        e.modification_time.should_satisfy { |m| m > e.creation_time }
        e.last_access_time.should == e.modification_time
    end

    specify "reading a field after assignment the access time > modification time " do
        e = Keybox::Storage::Record.new
        e.testing = "testing"
        sleep 1
        e.testing
        e.last_access_time.should_satisfy { |la| la > e.creation_time }
        e.last_access_time.should_satisfy { |la| la > e.modification_time }
    end

    specify "assigning to a modification, creation or acces_time should raise and exception " do
        e = Keybox::Storage::Record.new
        lambda {e.modification_time = Time.now}.should_raise NoMethodError
    end

    specify "assiging multiple items should raise an argument exception" do
        e = Keybox::Storage::Record.new
        lambda {e.send(:stuff=,1,2)}.should_raise ArgumentError
    end

    specify "calling a method with arguments should raise exception" do
        e = Keybox::Storage::Record.new
        lambda {e.stuff(1,2)}.should_raise NoMethodError
    end

    specify "comparison between records is valid" do
        e = Keybox::Storage::Record.new
        f = e.dup
        e.should_eql e.uuid
        e.should_eql f
    end
end
