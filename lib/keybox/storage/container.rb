require 'keybox/cipher'
require 'keybox/digest'
require 'keybox/storage/record'
require 'keybox/uuid'
require 'keybox/randomizer'
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

                if not load_from_file(@path,@passphrase) then
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

            def load_from_file(path,passphrase)
                tmp = YAML.load_file(path)
                if tmp then
                    @creation_time      = tmp.creation_time
                    @modification_time  = tmp.modification_time
                    @last_access_time   = tmp.last_access_time
                    @data_members       = tmp.data_members
                    true
                else
                    false
                end
            end

            def save(path = @path)
                File.open(path,"w") do |f|
                    f.write(self.to_yaml)
                end
            end

            def calculated_key(passphrase)
                key = self.key_digest_salt + passphrase
                self.key_calc_iterations.times do 
                    key = Keybox::Digest::CLASSES[self.key_digest_algorithm].digest(key)
                end
                return key
            end

            def calculated_key_digest(passphrase)
                Keybox::Digest::CLASSES[self.key_digest_algorithm].hexdigest(calculated_key(passphrase))
            end
        end
    end
end
