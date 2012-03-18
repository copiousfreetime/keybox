require 'openssl'
require 'yaml'

module Keybox
    module Storage
        ##
        # The container of the Keybox records.  The Container itself is
        # a Keybox::Storage::Record with a few extra methods.
        #
        # A instance of a Container is created with a passphrase and a
        # path to a file.  The passphrase can be anything that has a
        # to_s method.
        #
        #   container = Keybox::Storage::Container.new("i love ruby", "/tmp/database.yml")
        #
        # This will load from the given file with the given passphrase
        # if the file exists, or it will initialize the container to
        # accept records.
        #
        # The records are held decrypted in memory, so keep that in mind
        # if that is a concern.
        #
        # Add Records
        #
        #   record = Keybox::Storage::Record.new
        #   record.field1 = "data"
        #   record.field2 = "some more data"
        #
        #   container << record
        #
        # Delete Records
        #
        #   container.delete(record)
        #
        # There is no 'update' record, just delete it and add it.
        #
        # Find a record accepts a string and will look in all the
        # records it contains for anything that matches it.  It coerces
        # strings into +Regexp+ so any regex can be used here too.
        #
        #   container.find("data")
        #
        # Report if the container or any of its records have been
        # modified:
        #
        #   container.modified?
        #
        # Save the container to its default location:
        #
        #   container.save
        #
        # Or to some other location
        #
        #   container.save("/some/other/path.yml")
        #
        # Direct access to the decrypted records is also available
        # through the +records+ accessor.
        #
        #   container.records #=> Array of Keybox::Storage::Record
        #
        class Container < Keybox::Storage::Record

            attr_reader     :records

            ITERATIONS            = 2048
            MINIMUM_PHRASE_LENGTH = 4
            def initialize(passphrase,path)
                super()

                @path        = path
                @passphrase  = passphrase
                @records     = []

                if not load_from_file then
                    strength_check(@passphrase)
                    self.version                    = Keybox::VERSION

                    self.key_calc_iterations        = ITERATIONS
                    self.key_digest_salt            = Keybox::RandomDevice.random_bytes(32)
                    self.key_digest_algorithm       = Keybox::Digest::DEFAULT_ALGORITHM
                    self.key_digest                 = calculated_key_digest(passphrase)

                    self.records_init_vector        = Keybox::RandomDevice.random_bytes(16)
                    self.records_cipher_algorithm   = Keybox::Cipher::DEFAULT_ALGORITHM

                    self.records_encrypted_data     = ""
                    self.records_digest_salt        = Keybox::RandomDevice.random_bytes(32)
                    self.records_digest_algorithm   = Keybox::Digest::DEFAULT_ALGORITHM
                    self.records_digest             = ""
                end
            end

            #
            # Change the master password of the container
            #
            def passphrase=(new_passphrase)
                strength_check(new_passphrase)
                @passphrase                 = new_passphrase
                self.key_digest_salt        = Keybox::RandomDevice.random_bytes(32)
                self.key_digest             = calculated_key_digest(new_passphrase)
                self.records_init_vector    = Keybox::RandomDevice.random_bytes(16)
                self.records_digest_salt    = Keybox::RandomDevice.random_bytes(32)
            end

            #
            # load from file, if this is successful then replace the
            # existing member fields on this instance with the data from
            # the file
            #
            def load_from_file
                return false unless File.exists?(@path)
                return false unless tmp = YAML.load_file(@path)
                @creation_time      = tmp.creation_time
                @modification_time  = tmp.modification_time
                @last_access_time   = tmp.last_access_time
                @data_members       = tmp.data_members
                @uuid               = tmp.uuid
                validate_passphrase
                decrypt_records
                validate_decryption
                load_records
                @modified = false
                true
            end

            #
            # save the current container to a file
            #
            def save(path = @path)
                calculate_records_digest
                encrypt_records
                File.open(path,"w") do |f|
                    f.write(self.to_yaml)
                end

                # mark everything as not modified
                @records.each do |record|
                    record.modified = false
                end
                @modified = false
            end

            #
            # calculate the encryption key from the initial passphrase
            #
            def calculated_key(passphrase = @passphrase)
                key = self.key_digest_salt + passphrase
                self.key_calc_iterations.times do
                    key = Keybox::Digest::CLASSES[self.key_digest_algorithm].digest(key)
                end
                return key
            end

            #
            # calculate the key digest of the encryption key
            #
            def calculated_key_digest(passphrase)
                Keybox::Digest::CLASSES[self.key_digest_algorithm].hexdigest(calculated_key(passphrase))
            end

            #
            # Add a record to the system
            #
            def <<(obj)
                if obj.respond_to?("needs_container_passphrase?") and obj.needs_container_passphrase? then
                    obj.container_passphrase = @passphrase
                end
                @records << obj
            end

            #
            # The number of Records in the Container
            #
            def length
                @records.size
            end

            #
            # The number of Records in the Container
            #
            def size
                @records.size
            end

            #
            # Delete a record from the system, we force a modified flag
            # here since the underlying Record wasn't 'assigned to' we
            # have to force modification notification.
            #
            def delete(obj)
                @records.delete(obj)
                @modified = true
            end

            #
            # Search only records that have a +url+ field
            #
            def find_by_url(url)
                find(url,%w(url))
            end

            #
            # Search all the records in the database finding any that
            # match the search string passed in.  The Search string is
            # converted to a Regexp before beginning.
            #
            # A list of restricted fields can also be passed in and the
            # regexp will only be matched against those fields
            #
            def find(search_string,restricted_to = nil)
                case search_string
                when Regexp
                    regex = Regexp.new(search_string.source,search_string.options | Regexp::IGNORECASE)
                else
                    regex = Regexp.new(search_string.to_s,Regexp::IGNORECASE)
                end
                matches = []
                @records.each do |record|
                    restricted_to = restricted_to || ( record.data_member_names - %w(password) )
                    record.data_members.each_pair do |k,v|
                        if regex.match(v) and restricted_to.include?(k.to_s) then
                            matches << record
                            break
                        end
                    end
                end
                return matches
            end

            #
            # See if we are modified, or if any of the records are
            # modified
            #
            def modified?
                return true if super
                @records.each do |record|
                    return true if record.modified?
                end
                return false
            end

            private

            #
            # validate the passphrase against some criteria.  Right now
            # this criteria is very minimal and should be changed at
            # some point.
            #
            # An invalid passphrase raises a Keybox::ValidationException
            #
            def strength_check(phrase)
                if phrase.to_s.length < MINIMUM_PHRASE_LENGTH
                    raise Keybox::ValidationError, "Passphrase is not strong enough.  It is too short."
                end
                true
            end

            #
            # calculate the key digest of the input pass phrase and
            # compare that to the digest in the data file.  If they are
            # the same, then the pass phrase should be the correct one
            # for the data.
            #
            def validate_passphrase
                raise Keybox::ValidationError, "Passphrase digests do not match.  The passphrase given does not decrypt the data in this file." unless key_digest == calculated_key_digest(@passphrase)
            end

            #
            # encrypt the data in the records and store it in
            # records_encrypted_data
            #
            def encrypt_records
                cipher     = OpenSSL::Cipher::Cipher.new(self.records_cipher_algorithm)
                cipher.encrypt
                cipher.key = calculated_key
                cipher.iv  = self.records_init_vector
                self.records_encrypted_data  = cipher.update(@records.to_yaml)
                self.records_encrypted_data << cipher.final
            end

            #
            # decrypt the data in the record_data and store it in
            # records
            #
            def decrypt_records
                cipher     = OpenSSL::Cipher::Cipher.new(self.records_cipher_algorithm)
                cipher.decrypt
                cipher.key = calculated_key
                cipher.iv  = self.records_init_vector
                @decrypted_yaml  = cipher.update(self.records_encrypted_data)
                @decrypted_yaml << cipher.final
            end

            #
            # make sure that the decrypted data is validated against its
            # hash
            #
            def validate_decryption
                digest = Keybox::Digest::CLASSES[self.records_digest_algorithm]
                hexdigest = digest.hexdigest(self.records_digest_salt + @decrypted_yaml)
                raise Keybox::ValidationError, "Record digests do not match. The given passphrase does not decrypt the data." unless hexdigest == self.records_digest
            end


            def calculate_records_digest
                digest = Keybox::Digest::CLASSES[self.records_digest_algorithm]
                self.records_digest = digest.hexdigest(self.records_digest_salt + @records.to_yaml)
            end

            def load_records
                @records = YAML.load(@decrypted_yaml)

                # if a record wants, it can have a reference to the
                # container.
                @records.each do |record|
                    if record.respond_to?("needs_container_passphrase?") and record.needs_container_passphrase? then
                        record.container_passphrase = @passphrase
                    end
                end
            end
        end
    end
end
