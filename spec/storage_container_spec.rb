require 'keybox/storage'
require 'keybox/error'
require 'keybox/entry'
require 'openssl'
require 'tempfile'
require 'yaml'

context 'a storage container' do
    setup do
        @passphrase  = "i love ruby"
        @keybox_file = Tempfile.new("keybox").path
        @testing_file = "/tmp/testing.yml"
        @container   = Keybox::Storage::Container.new(@passphrase, @keybox_file)
        @container << Keybox::HostAccountEntry.new("test account","localhost","guest", "rubyrocks")
        @container << Keybox::URLAccountEntry.new("the times", "http://www.nytimes.com", "rubyhacker")
        @container.save
    end

    teardown do
        File.unlink(@testing_file) if File.exists?(@testing_file)
    end

    specify 'should have a uuid' do
        @container.uuid.should_satisfy { |uuid| uuid.to_s.length == 36 }
    end

    specify 'should have a valid key ' do
        @container.key_digest.should_satisfy { |kd| kd.length == 64 }
    end

    specify 'should save correctly to a file' do
        @container.save(@testing_file)
        File.size(@testing_file).should_satisfy { |s| s > 0 }
    end

    specify "should load correctly from a file" do
        @container.save(@testing_file)
        new_container = Keybox::Storage::Container.new(@passphrase,@testing_file)
        new_container.uuid.should == @container.uuid
    end

    specify "should validate passphrase" do
        nc = Keybox::Storage::Container.new("i love ruby", @keybox_file)
        nc.save(@testing_file)
        nc.key_digest.should_eql @container.key_digest
        lambda {
            Keybox::Storage::Container.new("i hate ruby", @testing_file)
        }.should_raise Keybox::ValidationError

    end

    specify "url accounts should have the correct password after save" do
        @container.save(@testing_file)
        new_container = Keybox::Storage::Container.new(@passphrase, @testing_file)
        recs = new_container.find_by_url("nytimes")
        new_container.records.size.should_eql 2
        recs.size.should_eql 1
        recs[0].password.should == "2f85a2e2f"
    end

    specify "can find matching records" do
        matches = @container.find(/times/)
        matches.size.should_be 1
    end

    specify "changing the password is safe" do
        @container.save(@testing_file)
        copy_of_container= Keybox::Storage::Container.new(@passphrase, @testing_file)
        times_1 = copy_of_container.find_by_url("nytimes").first

        @container.passphrase = "I love ruby too!"
        @container.save(@keybox_file)
        @container = Keybox::Storage::Container.new("I love ruby too!", @keybox_file)
        times_2 = @container.find_by_url("nytimes").first
        @container.modified?.should_eql false
        times_1.should_eql times_2
    end

    specify "a freshly loaded db has not been modified" do
        @container.modified?.should_eql false
    end

    specify "a modified db can be detected" do
        l1 = @container.find("localhost").first
        l1.username = "new username"
        @container.modified?.should_eql true
    end
end
