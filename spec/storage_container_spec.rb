require 'keybox/storage'
require 'openssl'
require 'tempfile'

context 'a storage container' do
    setup do
        @passphrase  = "i love ruby"
        @keybox_file = Tempfile.new("keybox").path
        @container = Keybox::Storage::Container.new(@passphrase, @keybox_file)
    end

    specify 'should have a uuid' do
        @container.uuid.should_satisfy { |uuid| uuid.to_s.length == 36 }
    end

    specify 'should have a valid key ' do
        @container.key_digest.should_satisfy { |kd| kd.length == 64 }
    end

    specify 'should save correctly to a file' do
        @container.save("/tmp/testing.yml")
        File.size("/tmp/testing.yml").should_satisfy { |s| s > 0 }
        File.unlink("/tmp/testing.yml")
    end

    specify "should load correctly from a file" do
        @container.save("/tmp/testing.yml")
        new_container = Keybox::Storage::Container.new(@passphrase,"/tmp/testing.yml")
        new_container.uuid.should_equal @container.uuid
    end

end
