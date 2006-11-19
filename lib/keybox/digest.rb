module Keybox
    module Digest
        SHA_256             = "sha256"
        DEFAULT_ALGORITHM   = SHA_256
        CLASSES             = { SHA_256 => OpenSSL::Digest::SHA256 }
        ALGORITHMS          = CLASSES.keys
    end
end
