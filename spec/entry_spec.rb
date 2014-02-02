require 'spec_helper'

describe "Account Entry" do
  it "fields get set correctly" do
    k = Keybox::AccountEntry.new("a test title", "user")
    k.username.must_equal "user"
    k.title.must_equal "a test title"
  end

  it "fields can be accessed" do
    k = Keybox::AccountEntry.new("a test title", "user")
    k.fields.must_include("title")
    k.fields.must_include("username")
    k.fields.must_include("additional_info")
  end

  it "fields can be private" do
    k = Keybox::AccountEntry.new("a test title", "user")
    k.private_fields.size.must_equal 0
  end
end

describe "Host Account" do
  it "fields get set correctly" do
    ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
    ha.title.must_equal "a title"
    ha.username.must_equal "user"
    ha.hostname.must_equal "host"
    ha.password.must_equal "password"
  end

  it "password is private" do
    ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
    ha.private_fields.must_include("password")
  end
end

describe "URL Account" do
  it "fields get set correctly" do
    urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
    urla.title.must_equal "url title"
    urla.url.must_equal "http://www.example.com"
    urla.username.must_equal "someuser"
  end

  it "password hash is used" do
    container = Keybox::Storage::Container.new("i love ruby", "/tmp/junk.yml")
    urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
    container << urla
    urla.password.must_equal "589c0d91d"
  end

  it "there is no password storage field, but there a private password field" do
    urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
    urla.fields.wont_include("password")
    urla.private_fields.must_include("password")
    urla.private_field?("password").must_equal true
  end

end
