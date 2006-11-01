module Keybox

    class RandomDevice
        DEVICES = [ "/dev/urandom", "/dev/random" ]

    end

    # the Randomizer will randomly pick a value from anything that is an
    # array or has a to_a method.  The source of randomness is
    # determined at runtime.  Any class that can provide a method 'rand'
    # can be a random source
    class Randomizer
    end
end
