require 'spec_helper'

describe "CSV Convert class" do
  before(:each) do 
    @import_csv = Tempfile.new("keybox_import.csv")
    @import_csv.puts "title,hostname,username,password,additional_info"
    @import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
    @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"
    @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login's information"
    @import_csv.close

    @bad_import_csv = Tempfile.new("keybox_bad_header.csv")
    # "ttle" is incorrect, "hostname" header is misnamed as "host"
    @bad_import_csv.puts "ttle,host,username,password,additional_info"
    @bad_import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
    @bad_import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"
    @bad_import_csv.close

    @export_csv = Tempfile.new("keybox_export.csv")

  end

  after(:each) do
    @import_csv.unlink
    @bad_import_csv.unlink
    @export_csv.unlink
  end

  it "able to load records from a file" do
    entries = Keybox::Convert::CSV.from_file(@import_csv.path)
    entries.size.should be == 3
    entries[0].hostname.should be == "host.example.com"
    entries[1].password.should be == "mywebpassword"
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
