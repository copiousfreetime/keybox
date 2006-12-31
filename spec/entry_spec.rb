context "Account Entry" do
    specify "fields get set correctly" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.username.should_eql "user"
        k.title.should_eql "a test title"
    end

    specify "fields can be accessed" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.fields.should_include "title"
        k.fields.should_include "username"
        k.fields.should_include "additional_info"
    end

    specify "fields can be private or visible" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.private_fields.size.should_eql 0
        k.visible_field?("title").should_eql true
    end
end

context "Host Account" do
    specify "fields get set correctly" do
        ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
        ha.title.should_eql "a title"
        ha.username.should_eql "user"
        ha.hostname.should_eql "host"
        ha.password.should_eql "password"
    end

    specify "password is displayable, private and non-visible" do
        ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
        ha.display_fields.should_include "password"
        ha.private_fields.should_include "password"
        ha.visible_fields.should_not_include "password"
    end
end

context "URL Account" do
    specify "fields get set correctly" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        urla.title.should_eql "url title"
        urla.url.should_eql "http://www.example.com"
        urla.username.should_eql "someuser"
    end

    specify "password hash is used" do
        container = Keybox::Storage::Container.new("i love ruby", "/tmp/junk.yml")
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        container << urla
        urla.password.should_eql "589c0d91d"
    end

    specify "there is no password storage field, but there a private password field" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.example.com", "someuser")
        urla.fields.should_not_include "password"
        urla.private_fields.should_include "password"
        urla.private_field?("password").should_eql true
    end

end
                                          
