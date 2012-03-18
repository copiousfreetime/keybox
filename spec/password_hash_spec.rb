require 'spec_helper'

describe "PasswordHash" do
    before(:each) do 
        @pwd_hash = Keybox::PasswordHash.new("i love ruby")
    end

    it "creates string for password" do
        pwd = @pwd_hash.password_for_url("http://www.nytimes.com")
        pwd.should == "2f85a2e2f"
    end
end
