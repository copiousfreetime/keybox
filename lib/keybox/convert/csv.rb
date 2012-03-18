require 'csv'
module Keybox
    module Convert
        #
        # Convert to/from a CSV file.  When loading a CSV file, it is assumed
        # that there is a header on the csv file that shows which of the fields
        # belongs to the various fields of the entry.  At a minimum the header
        # line should have the default fields from an HostAccountEntry which are:
        #
        #   - title
        #   - username
        #   - hostname
        #   - password
        #   - additional_info
        # 
        # These headers can be in any order and CSV will do the right
        # thing.  But these headers must exist.  A
        # Keybox::ValidationError is thrown if they do not.
        #       
        class CSV
            class << self 

                # parse the header line from the CSV file and make sure
                # that all the required columns are listed.
                #
                def parse_header(header) 
                    field_indexes = {}
                    Keybox::HostAccountEntry.default_fields.each do |field|
                        field_indexes[field] = header.index(field)
                        if field_indexes[field].nil? then
                            raise Keybox::ValidationError, "There must be a header on the CSV to import and it must contain the '#{field}' field."
                        end
                    end
                    field_indexes
                end

                # returns an Array of AccountEntry classes or its
                # descendants
                #
                def from_file(csv_filename)
                    reader = ::CSV.open(csv_filename,"r")
                    entries = from_reader(reader)
                    return entries
                ensure
                    reader.close
                end

                # pull all the items from the CSV file.  There MUST be a
                # header line that says what the different fields are.
                # A HostAccountEntry object is created for each line and
                # the array of those objects is returned
                #
                def from_reader(csv_reader)
                    field_indexes = parse_header(csv_reader.shift)
                    entries = []
                    csv_reader.each do |row|
                        entry = Keybox::HostAccountEntry.new
                        field_indexes.each_pair do |field,index|
                            value = row[index] || ""
                            entry.send("#{field}=",value.strip)
                        end
                        entries << entry
                    end
                    return entries
                end

                #
                # records should be an array of AccountEntry objects
                #
                def to_file(records,csv_filename)
                    writer = ::CSV.open(csv_filename,"w")
                    Keybox::Convert::CSV.to_writer(records,writer)
                    writer.close
                end

                #
                # write all the fields for each record.  We go through
                # all the records (an array of AccountEntry objects), 
                # recording all the fields, then using that as the header.  
                #
                def to_writer(records,csv_writer)
                    field_names = records.collect { |r| r.fields }.flatten.uniq
                    csv_writer << field_names
                    records.each do |record|
                        values = []
                        field_names.each do |field|
                            values << record.send(field) || ""
                        end
                        csv_writer << values
                    end
                end
            end 
        end
    end
end
