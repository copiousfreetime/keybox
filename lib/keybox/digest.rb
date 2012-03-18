require 'digest/sha2'
module Keybox
  #
  # By default Keybox wants to use sha-256 as the hashing function.
  # a sha-256 library ships with ruby in 'digest/sha2'
  #
  module Digest
    SHA_256           = "sha256"
    DEFAULT_ALGORITHM = SHA_256
    CLASSES           = { SHA_256 => ::Digest::SHA256 }
    ALGORITHMS        = CLASSES.keys
  end
end
