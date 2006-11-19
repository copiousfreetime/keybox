require 'keybox/storage'
require 'keybox/error'
require 'keybox/entry'
require 'openssl'
require 'tempfile'

context 'a storage container' do
    setup do
        @passphrase  = "i love ruby"
        @keybox_file = Tempfile.new("keybox").path
        @testing_file = "/tmp/testing.yml"
        @container   = Keybox::Storage::Container.new(@passphrase, @keybox_file)
        @container << Keybox::AccountEntry.new("localhost","guest", "rubyrocks")
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
        new_container.uuid.should_equal @container.uuid
    end

    specify "should validate passphrase" do
        nc = Keybox::Storage::Container.new("i love ruby", @keybox_file)
        nc.save(@testing_file)
        nc.key_digest.should_equal @container.key_digest
        lambda {
            Keybox::Storage::Container.new("i hate ruby", @testing_file)
        }.should_raise Keybox::ValidationError

    end
end
