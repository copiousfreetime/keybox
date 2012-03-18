require 'keybox/storage/record'

module Keybox

    # Entries in the Keybox storage container.  The base class is
    # AccountEntry with current child classes HostAccountEntry and
    # URLAccountEntry.
    #
    # In most cases HostAccountEntry will suffice.  Use URLAccountEntry
    # when you would like to link an entry's +password+ field to be
    # generated based upon the master password of the container.
    class AccountEntry < Keybox::Storage::Record
        class << self
            def default_fields
                %w(title username additional_info)
            end

            def private_fields
                []
            end

            def private_field?(field_name)
                private_fields.include?(field_name)
            end
        end

        def each
            fields.each do |f|
                yield [f,self.send(f)]
            end
        end

        # fields that are actually stored in the entry
        def fields
            (default_fields + @data_members.keys ).collect { |k| k.to_s }.uniq
        end

        def default_fields
            self.class.default_fields
        end

        def private_fields
            self.class.private_fields
        end

        def private_field?(field_name)
            self.class.private_field?(field_name)
        end

        def values
            fields.collect { |f| self.send(f) }
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

        def to_s
            s = StringIO.new
            max_length = self.max_field_length
            fields.each do |f|
                line = "#{f.rjust(max_length + 1)} :"
                value = self.send(f)
                if private_field?(f) then
                    # if its private field, then blank out value just to
                    value = " ***** private ***** "
                end
                s.puts "#{f.rjust(max_length + 1)} : #{value}"
            end
            return s.string
        end

        def max_field_length
            fields.collect { |f| f.length }.max
        end

    end

    #
    # Host Accounts are those typical login accounts on machines.  These
    # contain at a minimum the fields:
    #
    #   - title
    #   - hostname
    #   - username
    #   - pasword
    #   - additional_info
    #
    # Since HostAccountEntry is a descendant of Keybox::Storage::Record
    # other fields may be added dynamically.
    #
    class HostAccountEntry < Keybox::AccountEntry

        class << self
            def default_fields
                %w(title hostname username password additional_info)
            end

            def private_fields
                %w(password)
            end
        end

        def initialize(title = "",hostname = "",username = "",password = "")
            super(title,username)
            self.hostname = hostname
            self.password = password
        end

    end

    #
    # URLAccounts do not have a +password+ field, although it appears
    # to. It is calculated based upon the URL and the master password
    # for the Container.  The minimum fields for URLAccountEntry are:
    #
    #   - title
    #   - url
    #   - username
    #   - additional_info
    #
    # This is inspired by http://crypto.stanford.edu/PwdHash/ and
    # http://www.xs4all.nl/~jlpoutre/BoT/Javascript/PasswordComposer/
    #
    # This class also needs to be told the container's passphrase to
    # calculate its own password.
    #
    # TODO: Have this class use any other Keybox::Storage::Record
    # for the master password instead of the container.
    #
    class URLAccountEntry < Keybox::AccountEntry
        class << self
            def initial_fields
                %w(title url username additional_info)
            end

            def private_fields
                %w(password)
            end
        end

        def initialize(title = "",url = "",username = "")
            super(title,username)
            self.url = url
        end

        def password_hash_alg
            unless instance_variable_defined?(:@password_hash_alg)
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
