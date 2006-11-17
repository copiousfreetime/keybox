require 'keybox/randomizer'
module Keybox
    class UUID
        XF = "%0.2x"
        FORMAT = sprintf("%s-%s-%s-%s-%s", XF * 4, XF * 2, XF * 2, XF * 2, XF * 6)
        def initialize
            @bytes = Keybox::RandomDevice.random_bytes(16)
        end

        def to_s
            sprintf(FORMAT,*@bytes.unpack("C*"))
        end
    end
end
