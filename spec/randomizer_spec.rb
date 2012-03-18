require 'spec_helper'

describe "a random device class" do
  it "should have a default source" do
    Keybox::RandomDevice.default.should == "/dev/urandom"
  end

  it "should produce strings" do
    Keybox::RandomDevice.random_bytes.should be_an_instance_of(String)
  end

  it "should produce strings of a given length" do
    Keybox::RandomDevice.random_bytes(4).size.should == 4
  end

  it "should raise exception when given an invalid device" do
    Proc.new {Keybox::RandomDevice.default = "/tmp/junk" }.should raise_error( ArgumentError)
  end

  it "should be able to assign a new default source" do
    (Keybox::RandomDevice.default = "/dev/random").should be == "/dev/random"
    Keybox::RandomDevice.default = "/dev/urandom"
  end
end

describe "a random device instance" do
  before(:each) do
    @random_device = Keybox::RandomDevice.new
  end
  it "should have a source" do
    @random_device.source.should == "/dev/urandom"
  end

  it "should produce strings" do
    @random_device.random_bytes.should be_an_instance_of(String)
  end

  it "should produce strings of a given length" do
    @random_device.random_bytes(20).size.should == 20
  end

  it "should default to the RandomDevice default when given an invalid device " do
    rd = Keybox::RandomDevice.new("/tmp/bad-random-device")
    rd.source.should == Keybox::RandomDevice.default
  end

  it "should accept a valid readable device" do
    rd = Keybox::RandomDevice.new("/dev/random")
    rd.source.should == "/dev/random"
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

  it "should have a default" do
    Keybox::RandomSource.source.should_not == nil
  end

  it "invalid default class should throw exception " do
    lambda { Keybox::RandomSource.source = String }.should raise_error(ArgumentError)
  end

  it "valid class should allow default to be set" do
    (Keybox::RandomSource.source = JunkRandomSource).should be == JunkRandomSource
    Keybox::RandomSource.source_classes.should have(3).entries
    Keybox::RandomSource.source_classes.delete(JunkRandomSource)
    Keybox::RandomSource.source_classes.should have(2).entries
    Keybox::RandomSource.source.should == ::Keybox::RandomDevice
  end

  it "rand with no parameters should return a value between 0 and 1" do
    r = Keybox::RandomSource.rand
    r.should be >= 0.0
    r.should be < 1.0
  end

  it "rand with parameters should return an integer value between 0 and that value" do
    r = Keybox::RandomSource.rand(42)
    r.should be_a_kind_of(Integer)
    r.should < 42
  end
end

describe "a randomzier instance" do
  before(:each) do
    @randomizer = Keybox::Randomizer.new
    @hash       = { :stuff => "stuff", :things => "things" }
    @array      = ["foo", "bar", "baz" ]
  end
  it "should have a default random source" do
    @randomizer.random_source.should_not == nil
  end

  it "giving an invalid default random source should raise an exception" do
    lambda { r = Keybox::Randomizer.new(Array) }.should raise_error(ArgumentError)
  end

  it "picking from a non-array should raise an exception" do
    lambda { @randomizer.pick_count_from(@hash) }.should raise_error(ArgumentError)
  end

  it "picking one from an array should be okay" do
    @array.should be_include(@randomizer.pick_one_from(@array))
  end

  it "picking N from an array should result in an array" do
    @randomizer.pick_count_from(@array,3).should have(3).entries
    @randomizer.pick_count_from(@array,9).each do |arg|
      @array.should be_include(arg)
    end
  end
end
