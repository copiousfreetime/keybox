require 'keybox/uuid'
context "UUID class" do
    specify "should have 16 bytes" do
        uuid = Keybox::UUID.new
        uuid.bytes.size.should_equal 16 
    end

    specify "as an array should have 16 members" do
        uuid = Keybox::UUID.new
        uuid.to_a.size.should_equal 16
    end

    specify "array elements should have values between 0 and 256 " do
        uuid = Keybox::UUID.new
        uuid.to_a.each do |b|
            b.should_satisfy { |s| s.between?(0,256) }
        end
    end

    specify "as a string should match regex" do
        regex = Keybox::UUID::REGEX
        uuid  = Keybox::UUID.new
        uuid.to_s.should_match(regex)
    end

    specify "initialized with a string should give a valid uuid" do
        s      = "0123456789abcdef"
        s_a    = s.unpack("C*")
        s_uuid = sprintf(Keybox::UUID::FORMAT,*s_a)
        uuid = Keybox::UUID.new(s)
        uuid.to_s.should_equal(s_uuid)
    end

    specify "initialized with a string in the format of a uuid is valid " do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        uuid = Keybox::UUID.new(s)
        uuid.to_s.should_equal(s)
    end
    
    specify "not enough bytes should throw an expeption" do
        s = "0123456789"
        lambda { Keybox::UUID.new(s) }.should_raise ArgumentError
    end

    specify "invalid uuid string should throw an expeption" do
        s = "z8b5a23a-2507-4834-ab19-60f2cb2a5271"
        lambda { Keybox::UUID.new(s) }.should_raise ArgumentError
    end

    specify "should equal another keybox created with same data" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        two = Keybox::UUID.new(s)
        one.should_equal two
    end

    specify "should equal a string that is the same uuid" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        one.should_equal s
    end

    specify "should not equal some other uuid or random string" do
        s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
        one = Keybox::UUID.new(s)
        one.should_not_equal Keybox::UUID.new
        one.should_not_equal "i love ruby"
        one.should_not_equal 4
    end
end
