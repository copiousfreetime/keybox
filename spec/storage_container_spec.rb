require 'spec_helper'

describe 'a storage container' do
  before(:each) do
    @passphrase  = "i love ruby"
    @keybox_file = Tempfile.new("keybox").path
    @testing_file = "/tmp/testing.yml"
    @container   = Keybox::Storage::Container.new(@passphrase, @keybox_file)
    @container << Keybox::HostAccountEntry.new("test account","localhost","guest", "rubyrocks")
    @container << Keybox::URLAccountEntry.new("the times", "http://www.nytimes.com", "rubyhacker")
    @container.save
  end

  after(:each) do
    File.unlink(@testing_file) if File.exists?(@testing_file)
    File.unlink(@keybox_file) if File.exists?(@keybox_file)
  end

  it 'should have a uuid' do
    @container.uuid.to_s.length.should == 36
  end

  it 'should have a valid key ' do
    @container.key_digest.length.should == 64
  end

  it 'should save correctly to a file' do
    @container.save(@testing_file)
    File.size(@testing_file).should > 0
  end

  it "should load correctly from a file" do
    @container.save(@testing_file)
    new_container = Keybox::Storage::Container.new(@passphrase,@testing_file)
    new_container.should_be_not_modified
    new_container.uuid.should == @container.uuid
  end

  it "should validate passphrase" do
    nc = Keybox::Storage::Container.new("i love ruby", @keybox_file)
    nc.save(@testing_file)
    nc.key_digest.should be == @container.key_digest
    lambda { Keybox::Storage::Container.new("i hate ruby", @testing_file) }.should raise_error(Keybox::ValidationError)
  end

  it "url accounts should have the correct password after save" do
    @container.save(@testing_file)
    new_container = Keybox::Storage::Container.new(@passphrase, @testing_file)
    recs = new_container.find_by_url("nytimes")
    new_container.records.size.should be == 2
    recs.size.should be == 1
    recs[0].password.should == "2f85a2e2f"
  end

  it "can find matching records" do
    matches = @container.find(/times/)
    matches.size.should == 1
  end

  it "can find matching records - case insensitive via regex input" do
    matches = @container.find(/Times/)
    matches.size.should == 1
  end

  it "can find matching records - case insensitive via string input" do
    matches = @container.find("Times")
    matches.size.should == 1
  end

  it "changing the password is safe" do
    @container.save(@testing_file)
    copy_of_container= Keybox::Storage::Container.new(@passphrase, @testing_file)
    times_1 = copy_of_container.find_by_url("nytimes").first

    @container.passphrase = "I love ruby too!"
    @container.save(@keybox_file)
    @container = Keybox::Storage::Container.new("I love ruby too!", @keybox_file)
    times_2 = @container.find_by_url("nytimes").first
    times_1.should == times_2
  end

  it "should not be modified upon load" do
    @container.modified?.should == false
  end

  it "a modified db can be detected" do
    l1 = @container.find("localhost").first
    l1.username = "new username"
    @container.modified?.should == true
  end

  it "deleting an item should modify the container" do
    ll = @container.find("localhost").first
    @container.delete(ll)
    @container.modified?.should == true
  end

  it "able to see how many items are in the container" do
    @container.size.should be == 2
    @container.length.should == 2
  end
end
