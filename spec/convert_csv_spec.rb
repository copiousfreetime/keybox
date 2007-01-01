require 'tempfile'
require 'keybox'
require 'keybox/convert/csv'
context "CSV Convert class" do
    setup do 
        @import_csv = Tempfile.new("keybox_import.csv")
        @import_csv.puts "title,hostname,username,password,additional_info"
        @import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"
        @import_csv.close

        @bad_import_csv = Tempfile.new("keybox_bad_header.csv")
        # missing a valid header
        @bad_import_csv.puts "title,host,username,password,additional_info"
        @bad_import_csv.puts "example host,host.example.com,guest,mysecretpassword,use this account only for honeybots"
        @bad_import_csv.puts "example site,http://www.example.com,guest,mywebpassword,web forum login"

        @export_csv = Tempfile.new("keybox_export.csv")

    end

    teardown do
        @import_csv.unlink
        @bad_import_csv.unlink
        @export_csv.unlink
    end

    specify "able to load records from a file" do
        entries = Keybox::Convert::CSV.from_file(@import_csv.path)
        entries.size.should_eql 2
        entries[0].hostname.should_eql "host.example.com"
        entries[1].password.should_eql "mywebpassword"
    end

    specify "throws error if the header is bad" do
        lambda {
            Keybox::Convert::CSV.from_file(@bad_import_csv.path)
        }.should_raise Keybox::ValidationError
    end

    specify "able to write to a csv file" do
        entries = Keybox::Convert::CSV.from_file(@import_csv.path)
        Keybox::Convert::CSV.to_file(entries,@export_csv.path)
        @export_csv.open
        data = @export_csv.read
        data.size.should_be > 0
    end
end
