context "Account Entry" do
    specify "fields get set correctly" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.username.should_eql "user"
        k.title.should_eql "a test title"
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
end

context "URL Account" do
    specify "fields get set correctly" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.gmail.com", "someuser")
        urla.title.should_eql "url title"
        urla.url.should_eql "http://www.gmail.com"
        urla.username.should_eql "someuser"
    end

    specify "password hash is used" do
        container = Keybox::Storage::Container.new("i love ruby", "/tmp/junk.yml")
        urla = Keybox::URLAccountEntry.new("url title", "http://www.nytimes.com", "someuser")
        container << urla
        urla.password.should_eql "2f85a2e2f"
    end
end
                                          
