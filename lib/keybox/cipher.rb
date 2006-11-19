module Keybox
    module Cipher
        AES_256             = "aes256"
        DEFAULT_ALGORITHM   = AES_256
        CLASSES             = { AES_256 => OpenSSL::Cipher::AES256 }
        ALGORITHMS          = CLASSES.keys
    end
end
