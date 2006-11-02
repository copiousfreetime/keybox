require '../lib/keybox/randomizer'

context "a random device class" do
    specify "should have a default source" do
        Keybox::RandomDevice.default.should_equal "/dev/urandom" 
    end

    specify "should produce strings" do
        Keybox::RandomDevice.random_bytes.should_be_an_instance_of(String)
    end

    specify "should produce lengthy strings" do
        #Keybox::RandomDevice.random_bytes(4).should_have(4).things
        Keybox::RandomDevice.random_bytes(4).size.should_equal 4 
    end

    specify "should raise exception when given an invalid device" do
        Proc.new {Keybox::RandomDevice.default = "/tmp/junk" }.should_raise
    end
end

context "a random device instance" do
    setup do
        @random_device = Keybox::RandomDevice.new
    end
    specify "should have a source" do
        @random_device.source.should_equal "/dev/urandom"
    end

    specify "should produce strings" do
        @random_device.random_bytes.should_be_an_instance_of(String)
    end

    specify "should produce lengthy strings" do
        #@random_device.random_bytes(20).should_have(20).things
        @random_device.random_bytes(20).size.should_equal 20 
    end

    specify "should default to the RandomDevice default when given an invalid device " do 
        rd = Keybox::RandomDevice.new("/tmp/bad-random-device")
        rd.source.should_equal Keybox::RandomDevice.default
    end

    specify "should accept a valid readable device" do
        rd = Keybox::RandomDevice.new("/dev/random")
        rd.source.should_equal "/dev/random"
    end
end
