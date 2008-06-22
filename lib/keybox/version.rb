require 'keybox'

module Keybox
    class Version
        MAJOR   = 1 
        MINOR   = 2 
        BUILD   = 0 

        class << self
            def to_a
                [MAJOR, MINOR, BUILD]
            end

            def to_s
                to_a.join(".")
            end
        end
    end 
    VERSION = Version.to_s
end

