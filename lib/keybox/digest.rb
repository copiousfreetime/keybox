require 'openssl'
module Keybox
    #
    # By default Keybox wants to use sha-256 as the hashing function.
    # This is available in OpenSSL 0.9.8 or greater.
    #
    module Digest
        SHA_256             = "sha256"
        CLASSES             = { SHA_256 => ::OpenSSL::Digest::SHA256 } 
        DEFAULT_ALGORITHM   = SHA_256
        ALGORITHMS = CLASSES.keys
    end
end
