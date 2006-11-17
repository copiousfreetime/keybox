require 'keybox/storage/entry'
require 'keybox/uuid'
module Keybox
    module Storage
        class Container < Keybox::Storage::Entry
            def initialize
                self.uuid = Keybox::UUID.new
            end
        end
    end
end
