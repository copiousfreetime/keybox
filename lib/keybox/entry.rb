require 'keybox/storage/record'

module Keybox

    # 
    # Base class for Accounts.  Generally this is not instantiated
    # directly, but it can be if you want.
    #
    class AccountEntry < Keybox::Storage::Record

        def fields
            @data_members.keys.sort
        end

        def initialize(title = "",username = "")
            super()
            self.title              = title
            self.username           = username
            self.additional_info    = ""
        end

        def needs_container_passphrase?
            false
        end
    end

    #
    # Host Accounts are those typical login accounts on machines
    #
    class HostAccountEntry < Keybox::AccountEntry

        def fields
            %w(title hostname username password additional_info)
        end

        def initialize(title = "",hostname = "",username = "",password = "")
            super(title,username)
            self.hostname = hostname
            self.password = password
        end
    end

    #
    # URLAccounts do not have a password.  It is calculated based upon
    # the URL and the master password for the database.
    #
    # This class requires a handle to the container so that it can
    # calculate the password for the account.
    #
    class URLAccountEntry < Keybox::AccountEntry
        def fields
            %w(title url username additional_info)
        end

        def initialize(title = "",url = "",username = "")
            super(title,username)
            self.url = url
        end

        def password_hash_alg
            if not instance_variables.include?("@password_hash_alg") then
                @password_hash_alg = Keybox::PasswordHash.new
            end
            @password_hash_alg
        end

        def needs_container_passphrase?
            true
        end

        def container_passphrase=(p)
            password_hash_alg.master_password = p.dup
        end

        def password
            password_hash_alg.password_for_url(self.url)
        end

    end

end
