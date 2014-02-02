require 'spec_helper'

describe "UUID class" do
  it "as an array it has 16 members" do
    uuid = Keybox::UUID.new
    uuid.to_a.size.must_equal 16
  end

  it "array elements have values between 0 and 256 " do
    uuid = Keybox::UUID.new
    uuid.to_a.each do |b|
      b.must_be( :>=, 0 )
      b.must_be( :<=, 256 )
    end
  end

  it "as a string it matches regex" do
    regex = Keybox::UUID::REGEX
    uuid  = Keybox::UUID.new
    uuid.to_s.must_match( regex )
  end

  it "initialized with a string gives a valid uuid" do
    s      = "0123456789abcdef"
    s_a    = s.unpack("C*")
    s_uuid = sprintf(Keybox::UUID::FORMAT,*s_a)
    uuid = Keybox::UUID.new(s)
    uuid.to_s.must_equal s_uuid
  end

  it "initialized with a string in the format of a uuid is valid " do
    s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
    uuid = Keybox::UUID.new(s)
    uuid.to_s.must_equal s
  end

  it "not enough bytes throws an expeption" do
    s = "0123456789"
    lambda { Keybox::UUID.new(s) }.must_raise(ArgumentError)
  end

  it "invalid uuid string throws an exception" do
    s = "z8b5a23a-2507-4834-ab19-60f2cb2a5271"
    lambda { Keybox::UUID.new(s) }.must_raise(ArgumentError)
  end

  it "initialing with a non-string raises an exception" do
    lambda { Keybox::UUID.new(42) }.must_raise(ArgumentError)
  end

  it "equals another keybox created with same data" do
    s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
    one = Keybox::UUID.new(s)
    two = Keybox::UUID.new(s)
    one.must_equal two
  end

  it "equals a string that is the same uuid" do
    s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
    one = Keybox::UUID.new(s)
    one.must_equal s
  end

  it "does not equal some other uuid or random string" do
    s = "c8b5a23a-2507-4834-ab19-60f2cb2a5271"
    one = Keybox::UUID.new(s)
    one.wont_equal Keybox::UUID.new
    one.wont_equal "i love ruby"
    one.wont_equal 4
  end

  it "can be round-tripped with yaml multiple times" do
    uuid = Keybox::UUID.new
    yaml = uuid.to_yaml
    restored = YAML.load(yaml)
    restored.must_equal uuid
    YAML.load(restored.to_yaml).must_equal uuid
  end
end
