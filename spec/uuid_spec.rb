require 'spec_helper'

describe "UUID class" do
    it "as an array should have 16 members" do
        uuid = Keybox::UUID.new
        uuid.to_a.size.should == 16
    end

    it "array elements should have values between 0 and 256 " do
        uuid = Keybox::UUID.new
        uuid.to_a.each do |b|
            b.should be >= 0
            b.should be <= 256
        end
    end

    it "as a string should match regex" do
        regex = Keybox::UUID::REGEX
        uuid  = Keybox::UUID.new
        uuid.to_s.should =~ regex
    end

    it "initialized with a string should give a valid uuid" do
        s      = "0123456789abcdef"
        s_a    = s.unpack("C*")
        s_uuid = sprintf(Keybox::UUID::FORMAT,*s_a)
        uuid = Keybox::UUID.new(s)
        uuid.to_s.should == s_uuid
    end

    it "initialized with a string in the format of a uuid is valid " do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        uuid = Keybox::UUID.new(s)
        uuid.to_s.should == s
    end
    
    it "not enough bytes should throw an expeption" do
        s = "0123456789"
        lambda { Keybox::UUID.new(s) }.should raise_error(ArgumentError)
    end

    it "invalid uuid string should throw an exception" do
        s = "z8b5a23a-2507-4834-ab19-60f2cb2a5271"
        lambda { Keybox::UUID.new(s) }.should raise_error(ArgumentError)
    end

    it "initialing with a non-string raises an exception" do
        lambda { Keybox::UUID.new(42) }.should raise_error(ArgumentError)
    end

    it "should equal another keybox created with same data" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        two = Keybox::UUID.new(s)
        one.should == two
    end

    it "should equal a string that is the same uuid" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        one.should == s
    end

    it "should not equal some other uuid or random string" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        one.should_not be == Keybox::UUID.new
        one.should_not be == "i love ruby"
        one.should_not be == 4
    end

    it "can be round-tripped with yaml multiple times" do
        uuid = Keybox::UUID.new
        yaml = uuid.to_yaml
        restored = YAML.load(yaml)
        restored.should be == uuid
        YAML.load(restored.to_yaml).should == uuid
    end
end
