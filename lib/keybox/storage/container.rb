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

                if not load_from_file then
                    self.uuid                       = Keybox::UUID.new
                    self.version                    = Keybox::VERSION
                    
                    self.key_calc_iterations        = ITERATIONS
                    self.key_digest_salt            = Keybox::RandomDevice.random_bytes(32)
                    self.key_digest_algorithm       = Keybox::Digest::DEFAULT_ALGORITHM
                    self.key_digest                 = calculated_key_digest(passphrase)

                    self.record_init_vector         = Keybox::RandomDevice.random_bytes(16)
                    self.record_cipher_algorithm    = Keybox::Cipher::DEFAULT_ALGORITHM

                    self.record_digest_salt         = Keybox::RandomDevice.random_bytes(32)
                    self.record_digest_algorithm    = Keybox::Digest::DEFAULT_ALGORITHM
                    self.record_data                = ""
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
                decrypt_data
                validate_decryption
                true
            end

            #
            # save the current container to a file
            #
            def save(path = @path)
                File.open(path,"w") do |f|
                    f.write(self.to_yaml)
                end
            end

            #
            # calculate the encryption key from the initial passphrase
            #
            def calculated_key(passphrase)
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
        end
    end
end
