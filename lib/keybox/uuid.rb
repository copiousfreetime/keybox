require 'keybox/randomizer'
require 'yaml'
module Keybox
    #
    # A quick implementation of a UUID class using the internal
    # randomizer for byte generation
    # 
    class UUID

        XF     = "%0.2x"
        FORMAT = sprintf("%s-%s-%s-%s-%s", XF * 4, XF * 2, XF * 2, XF * 2, XF * 6)
        REGEX  = %r|^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$|

        #
        # the UUID can be initialized with:
        #   - nothing ( default case ) in this case the UUID is generated
        #   - a string in the standarde uuid format, in this case it is
        #     decoded and converted to the internal format
        #   - a string of bytes, in this case they are considered to be
        #     the bytes used internally so 16 of them are taken
        def initialize(bytes = nil)
            if bytes.nil? then
                @bytes = Keybox::RandomDevice.random_bytes(16)
            elsif bytes.size == 36 and bytes.split("-").size == 5 then
                if bytes =~ REGEX then
                    # remove the dashes and make sure that we're all
                    # lowercase
                    b = bytes.gsub(/-/,'').downcase

                    # convert to an array of hex strings
                    b = b.unpack("a2"*16)

                    # convert the hex strings to integers
                    b.collect! { |x| x.to_i(16) }

                    # and pack those integers into a string
                    @bytes = b.pack("C*")

                    # of course this could all be done in one line with
                    # @bytes = bytes.gsub(/-/,'').downcase.unpack("a2"*16").collect {|x| x.to_i(16) }.pack("C*")
                else
                    raise ArgumentError, "[#{bytes}] is not a hex encoded UUID"
                end
            elsif bytes.kind_of?(String) and bytes.length >= 16
                @bytes = bytes[0..16]
            else
                raise ArgumentError, "[#{bytes}] cannot be converted to a UUID"
            end

        end

        #
        # convert the bytes to the hex encoded string format of
        # XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
        # 
        def to_s
            sprintf(FORMAT,*to_a)
        end
        
        def to_a
            @bytes.unpack("C*")
        end

        def ==(other)
            self.eql?(other)
        end

        def eql?(other)
            case other
            when Keybox::UUID
                self.to_s == other.to_s
            when String
                begin
                    o = Keybox::UUID.new(other)
                    self == o
                rescue 
                    false
                end
            else
                false
            end
        end
    end
end
