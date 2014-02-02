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

  it 'has a uuid' do
    @container.uuid.to_s.length.must_equal 36
  end

  it 'has a valid key ' do
    @container.key_digest.length.must_equal 64
  end

  it 'saves correctly to a file' do
    @container.save(@testing_file)
    File.size(@testing_file).must_be( :>, 0 )
  end

  it "loads correctly from a file" do
    @container.save(@testing_file)
    new_container = Keybox::Storage::Container.new(@passphrase,@testing_file)
    new_container.wont_be(:modified?)
    new_container.uuid.must_equal @container.uuid
  end

  it "validates passphrase" do
    nc = Keybox::Storage::Container.new("i love ruby", @keybox_file)
    nc.save(@testing_file)
    nc.key_digest.must_equal @container.key_digest
    lambda { Keybox::Storage::Container.new("i hate ruby", @testing_file) }.must_raise(Keybox::ValidationError)
  end

  it "url accounts have the correct password after save" do
    @container.save(@testing_file)
    new_container = Keybox::Storage::Container.new(@passphrase, @testing_file)
    recs = new_container.find_by_url("nytimes")
    new_container.records.size.must_equal 2
    recs.size.must_equal 1
    recs[0].password.must_equal "2f85a2e2f"
  end

  it "can find matching records" do
    matches = @container.find(/times/)
    matches.size.must_equal 1
  end

  it "can find matching records - case insensitive via regex input" do
    matches = @container.find(/Times/)
    matches.size.must_equal 1
  end

  it "can find matching records - case insensitive via string input" do
    matches = @container.find("Times")
    matches.size.must_equal 1
  end

  it "changing the password is safe" do
    @container.save(@testing_file)
    copy_of_container= Keybox::Storage::Container.new(@passphrase, @testing_file)
    times_1 = copy_of_container.find_by_url("nytimes").first

    @container.passphrase = "I love ruby too!"
    @container.save(@keybox_file)
    @container = Keybox::Storage::Container.new("I love ruby too!", @keybox_file)
    times_2 = @container.find_by_url("nytimes").first
    times_1.must_equal times_2
  end

  it "is not be modified upon load" do
    @container.wont_be(:modified?)
  end

  it "a modified db can be detected" do
    l1 = @container.find("localhost").first
    l1.username = "new username"
    @container.must_be(:modified?)
  end

  it "deleting an item modifies the container" do
    ll = @container.find("localhost").first
    @container.delete(ll)
    @container.must_be(:modified?)
  end

  it "able to see how many items are in the container" do
    @container.size.must_equal 2
    @container.length.must_equal 2
  end
end
