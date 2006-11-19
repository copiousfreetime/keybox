require 'keybox/storage/record'

module Keybox
    class AccountEntry < Keybox::Storage::Record
        def initialize(hostname,username,password)
            super()
            self.hostname = hostname
            self.username = username
            self.password = password
        end
    end
end
