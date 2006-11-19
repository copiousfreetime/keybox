require 'keybox/cipher'
require 'keybox/digest'
require 'keybox/storage/record'
require 'keybox/uuid'
require 'keybox/randomizer'
require 'keybox/error'
require 'openssl'
require 'yaml'

module Keybox
    module Storage
        class Container < Keybox::Storage::Record

            ITERATIONS = 2048 
            def initialize(passphrase,path)
                super()

                @path        = path
                @passphrase  = passphrase
                @records     = []

                if not load_from_file then
                    self.uuid                       = Keybox::UUID.new
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
                validate_passphrase
                decrypt_records
                validate_decryption
                load_records
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

            def <<(obj)
                @records << obj
            end
            private

            #
            # calculate the key digest of the input pass phrase and
            # compare that to the digest in the data file.  If they are
            # the same, then the pass phrase should be the correct one
            # for the data.
            #
            def validate_passphrase
                raise Keybox::ValidationError, "Passphrase digests do not match.  The passphrase given does not decrypt the data in this file" unless key_digest == calculated_key_digest(@passphrase)
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
            end
        end
    end
end
