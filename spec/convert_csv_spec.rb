require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe "CSV Convert class" do
    before(:each) do 
        @import_csv = Tempfile.new("keybox_import.csv")
        @import_csv.puts "title,hostname,username,password,additional_info"
        @import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"
        @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login's information"
        @import_csv.close

        @bad_import_csv = Tempfile.new("keybox_bad_header.csv")
        # missing a valid header
        @bad_import_csv.puts "ttle,host,username,password,additional_info"
        @bad_import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @bad_import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"

        @export_csv = Tempfile.new("keybox_export.csv")

    end

    after(:each) do
        @import_csv.unlink
        @bad_import_csv.unlink
        @export_csv.unlink
    end

    it "able to load records from a file" do
        entries = Keybox::Convert::CSV.from_file(@import_csv.path)
        entries.size.should == 3
        entries[0].hostname.should == "host.example.com"
        entries[1].password.should == "mywebpassword"
        entries[2].additional_info.should == "web forum login's information"
    end

    it "throws error if the header is bad" do
        lambda { Keybox::Convert::CSV.from_file(@bad_import_csv.path) }.should raise_error(Keybox::ValidationError)
    end

    it "able to write to a csv file" do
        entries = Keybox::Convert::CSV.from_file(@import_csv.path)
        Keybox::Convert::CSV.to_file(entries,@export_csv.path)
        @export_csv.open
        data = @export_csv.read
        data.size.should > 0
    end
end
