require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
describe "Account Entry" do
    it "fields get set correctly" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.username.should be == "user"
        k.title.should == "a test title"
    end

    it "fields can be accessed" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.fields.should be_include("title")
        k.fields.should be_include("username")
        k.fields.should be_include("additional_info")
    end

    it "fields can be private" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.private_fields.size.should be == 0
    end
end

describe "Host Account" do
    it "fields get set correctly" do
        ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
        ha.title.should be == "a title"
        ha.username.should be == "user"
        ha.hostname.should be == "host"
        ha.password.should be == "password"
    end

    it "password is private" do
        ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
        ha.private_fields.should be_include("password")
    end
end

describe "URL Account" do
    it "fields get set correctly" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        urla.title.should be == "url title"
        urla.url.should be == "http://www.example.com"
        urla.username.should == "someuser"
    end

    it "password hash is used" do
        container = Keybox::Storage::Container.new("i love ruby", "/tmp/junk.yml")
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        container << urla
        urla.password.should == "589c0d91d"
    end

    it "there is no password storage field, but there a private password field" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        urla.fields.should_not be_include("password")
        urla.private_fields.should be_include("password")
        urla.private_field?("password").should == true
    end

end
