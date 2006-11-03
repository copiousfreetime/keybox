require 'keybox/randomizer'

context "a random device class" do
    specify "should have a default source" do
        Keybox::RandomDevice.default.should_equal "/dev/urandom" 
    end

    specify "should produce strings" do
        Keybox::RandomDevice.random_bytes.should_be_an_instance_of(String)
    end

    specify "should produce strings of a given length" do
        Keybox::RandomDevice.random_bytes(4).size.should_equal 4 
    end

    specify "should raise exception when given an invalid device" do
        Proc.new {Keybox::RandomDevice.default = "/tmp/junk" }.should_raise
    end

    specify "should be able to assign a new default source" do
        (Keybox::RandomDevice.default = "/dev/random").should_equal "/dev/random"
        Keybox::RandomDevice.default = "/dev/urandom"
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

    specify "should produce strings of a given length" do
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

context "a random source class " do
    setup do
        @random_source_class = mock("JunkRandomSource")
        @random_source_class.should_receive("random_bytes").at_least(0).times
    end
    specify "should have a default" do
        Keybox::RandomSource.source.should_not_equal nil
    end

    specify "invalid default class should throw exception " do
        lambda { KeyBox::RandomSource.source = String }.should_raise
    end

    specify "valid class should allow default to be set" do
        (Keybox::RandomSource.source = @random_source_class).should_equal @random_source_class
        Keybox::RandomSource.source_classes.should_have(3).entries
        Keybox::RandomSource.source_classes.delete(@random_source_class)
        Keybox::RandomSource.source_classes.should_have(2).entries
        Keybox::RandomSource.source.should_equal ::Keybox::RandomDevice
    end

    specify "rand with no parameters should return a value between 0 and 1" do
        r = Keybox::RandomSource.rand
        r.should_satisfy { |arg| arg >= 0.0 and arg < 1.0 }
    end

    specify "rand with parameters should return an integer value between 0 and that value" do
        r = Keybox::RandomSource.rand(42)
        r.should_be_a_kind_of(Integer)
        r.should_be < 42
    end
end
