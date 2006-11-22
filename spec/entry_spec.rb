context "Account Entry" do
    specify "fields get set correctly" do
        k = Keybox::AccountEntry.new("a test title", "user")
        k.username.should_equal "user"
        k.title.should_equal "a test title"
    end
end

context "Host Account" do
    specify "fields get set correctly" do
        ha = Keybox::HostAccountEntry.new("a title", "host", "user", "password")
        ha.title.should_equal "a title"
        ha.username.should_equal "user"
        ha.hostname.should_equal "host"
        ha.password.should_equal "password"
    end
end

context "URL Account" do
    specify "fields get set correctly" do
        urla = Keybox::URLAccountEntry.new("url title", "http://www.gmail.com", "someuser")
        urla.title.should_equal "url title"
        urla.url.should_equal "http://www.gmail.com"
        urla.username.should_equal "someuser"
    end

    specify "password hash is used" do
        container = Keybox::Storage::Container.new("i love ruby", "/tmp/junk.yml")
        urla = Keybox::URLAccountEntry.new("url title", "http://www.nytimes.com", "someuser")
        container << urla
        urla.password.should_equal "2f85a2e2f"
    end
end
                                          
