require 'keybox'
context "PasswordHash" do
    setup do 
        @pwd_hash = Keybox::PasswordHash.new("i love ruby")
    end
    specify "must be initialized with a master password" do
        lambda { Keybox::PasswordHash.new }.should_raise
    end

    specify "creates string for password" do
        pwd = @pwd_hash.password_for_url("http://www.nytimes.com")
        pwd.should_be == "2f85a2e2f"
    end
end