require 'openssl'
module Keybox
    #
    # By default Keybox wants to use sha-256 as the hashing function.
    # But if it is not available, which is the case on some OpenSSL's
    # Then fall back to sha1
    #
    module Digest
        SHA_1               = "sha1"
        SHA_256             = "sha256"
        CLASSES             = { SHA_1 => ::OpenSSL::Digest::SHA1 } 
       
        begin
            CLASSES[SHA_256]    = ::OpenSSL::Digest::SHA256
            DEFAULT_ALGORITHM   = SHA_256
        rescue NameError => ne
            # not all installations of ruby have an openssl that
            # supports SHA256
            DEFAULT_ALGORITHM = SHA_1
        end

        ALGORITHMS = CLASSES.keys
    end
end
