#
# Convert to/from a CSV file.  When loading a CSV file, it is assumed
# that there is a header on the csv file that shows which of the fields
# belongs to the various fields of the entry.  At a minimum the header
# line should have:
#
#   - username
#   - hostname or url
#   - password
#   - additional information
#
# A hostname or url can be used interchangeably same.  Either will work.
# If both are present both will be stored, but if only one is present
# then it will be stored in the hostname field of the HostAccount Record
#
#
