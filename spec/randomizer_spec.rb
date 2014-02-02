require 'spec_helper'

describe "a random device class" do
  it "has a default source" do
    Keybox::RandomDevice.default.must_equal "/dev/urandom"
  end

  it "produces strings" do
    Keybox::RandomDevice.random_bytes.must_be_instance_of(String)
  end

  it "produces strings of a given length" do
    Keybox::RandomDevice.random_bytes(4).size.must_equal 4
  end

  it "raises exception when given an invalid device" do
    Proc.new {Keybox::RandomDevice.default = "/tmp/junk" }.must_raise( ArgumentError)
  end

  it "is able to assign a new default source" do
    (Keybox::RandomDevice.default = "/dev/random").must_equal "/dev/random"
    Keybox::RandomDevice.default = "/dev/urandom"
  end
end

describe "a random device instance" do
  before(:each) do
    @random_device = Keybox::RandomDevice.new
  end
  it "has a source" do
    @random_device.source.must_equal "/dev/urandom"
  end

  it "produces strings" do
    @random_device.random_bytes.must_be_instance_of(String)
  end

  it "produces strings of a given length" do
    @random_device.random_bytes(20).size.must_equal 20
  end

  it "defaults to the RandomDevice default when given an invalid device " do
    rd = Keybox::RandomDevice.new("/tmp/bad-random-device")
    rd.source.must_equal Keybox::RandomDevice.default
  end

  it "accepts a valid readable device" do
    rd = Keybox::RandomDevice.new("/dev/random")
    rd.source.must_equal "/dev/random"
  end
end

class JunkRandomSource
  def self.random_bytes( f )
  end
end

describe "a random source class " do
  after(:each) do
    Keybox::RandomSource.source_classes.delete( ::JunkRandomSource )
  end

  it "has a default" do
    Keybox::RandomSource.source.wont_be_nil
  end

  it "invalid default class throws exception " do
    lambda { Keybox::RandomSource.source = String }.must_raise(ArgumentError)
  end

  it "valid class allows default to be set" do
    (Keybox::RandomSource.source = JunkRandomSource).must_equal JunkRandomSource
    Keybox::RandomSource.source_classes.size.must_equal 3
    Keybox::RandomSource.source_classes.delete(JunkRandomSource)
    Keybox::RandomSource.source_classes.size.must_equal 2
    Keybox::RandomSource.source.must_equal ::Keybox::RandomDevice
  end

  it "rand with no parameters returns a value between 0 and 1" do
    r = Keybox::RandomSource.rand
    r.must_be( :>=, 0.0 )
    r.must_be( :<, 1.0 )
  end

  it "rand with parameters returns an integer value between 0 and that value" do
    r = Keybox::RandomSource.rand(42)
    r.must_be_kind_of(Integer)
    r.must_be( :<, 42)
  end
end

describe "a randomzier instance" do
  before(:each) do
    @randomizer = Keybox::Randomizer.new
    @hash       = { :stuff => "stuff", :things => "things" }
    @array      = ["foo", "bar", "baz" ]
  end
  it "has a default random source" do
    @randomizer.random_source.wont_be_nil
  end

  it "giving an invalid default random source raises an exception" do
    lambda { Keybox::Randomizer.new(Array) }.must_raise(ArgumentError)
  end

  it "picking from a non-array raises an exception" do
    lambda { @randomizer.pick_count_from(@hash) }.must_raise(ArgumentError)
  end

  it "picking one from an array is okay" do
    @array.must_include(@randomizer.pick_one_from(@array))
  end

  it "picking N from an array results in an array" do
    @randomizer.pick_count_from(@array,3).size.must_equal 3
    @randomizer.pick_count_from(@array,9).each do |arg|
      @array.must_include(arg)
    end
  end
end
