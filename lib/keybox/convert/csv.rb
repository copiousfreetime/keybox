#
# Convert to/from a CSV file.  When loading a CSV file, it is assumed
# that there is a header on the csv file that shows which of the fields
# belongs to the various fields of the entry.  At a minimum the header
# line should have the default fields from a HostAccountEntry
#
#   - title
#   - username
#   - hostname
#   - password
#   - additional information
#
# A hostname or url can be used interchangeably same.  Either will work.
# If both are present both will be stored, but if only one is present
# then it will be stored in the hostname field of the HostAccount Record
#
require 'csv'
require 'keybox/entry'
module Keybox
    module Convert
        class CSV
            class << self 
                def parse_header(header_array) 
                    field_indexes = {}
                    Keybox::HostAccountEntry.default_fields.each do |field|
                        field_indexes[field] = header.index(field)
                        if field_indexes[field].nil? then
                            raise Keybox::ValidationError, "There must be a heder on the CSV to import and it must contain the '#{field}' field."
                        end
                    end
                    field_indexes
                end

                # returns an Array of AccountEntry classes or its
                # descendants
                def from_file(csv_filename)
                    reader = CSV.open(csv_filename,"r")
                    Keybox::Convert::CSV.from_reader(reader)
                    reader.close
                end

                # pull all the items from the CSV file.  There MUST be a
                # header line that says what the different fields are.
                def from_reader(csv_reader)
                    field_indexes = parse_header(csv_reader.shift)
                    entries = []
                    csv_reader.each do |row|
                        entry = Keybox::HostAccountEntry.new
                        field_indexes.each_pair do |field,index|
                            entry.send("#{field}=",row[index] || "")
                        end
                        entries << entry
                    end
                    return entries
                end

                def to_file(csv_filename)
                end

                def to_writer(csv_writer)
                end
            end 
        end
    end
end
