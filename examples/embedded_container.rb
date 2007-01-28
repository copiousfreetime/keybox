# Example snippit of code to show how you can roll your own encrypted
# container.
require  'keybox'
include Keybox

PASSPHRASE = "passphrase"
DB_PATH    = "/tmp/database.yaml"

File.unlink(DB_PATH) if File.exists?(DB_PATH)
container = Storage::Container.new(PASSPHRASE,DB_PATH)

# use the already existing HostAccountEntry 
container << HostAccountEntry.new("My DB Login", 
                                  "db.example.com", 
                                  "dbmanager", 
                                  "a really good password")
container.save


c2 = Storage::Container.new(PASSPHRASE,DB_PATH)

c2.find("example").each do |c| 
    puts c
end
puts "=" * 20
puts c2.find(/com/).first
