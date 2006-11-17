require 'keybox/storage/record'
require 'keybox/uuid'
module Keybox
    module Storage
        class Container < Keybox::Storage::Record
            def initialize
                self.uuid = Keybox::UUID.new
            end
        end
    end
end
