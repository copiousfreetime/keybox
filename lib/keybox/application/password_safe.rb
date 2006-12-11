require 'keybox/storage'
require 'keybox/application/base'
require 'optparse'
require 'ostruct'
require 'uri'

#-----------------------------------------------------------------------
# The Password Safe application
#-----------------------------------------------------------------------
module Keybox
    module Application 
        class PasswordSafe < Base
            include Keybox::TermIO

            attr_accessor :actions
            attr_reader   :db

            DEFAULT_DIRECTORY = File.join(ENV["HOME"],'.keybox')
            DEFUALT_DB        = File.join(DEFAULT_DIRECTORY,"database.yaml")
            DEFUALT_CONFIG    = File.join(DEFAULT_DIRECTORY,"config.yaml")

            ACTION_LIST       = %w(add delete edit show list master-password)

            def initialize(argv = [])
                @actions = Array.new
                super(argv)
                
                # only one of the actions is allowed
                if actions.size > 1 then
                    @error_message = [ "ERROR: Only one of #{ACTION_LIST.join(",")} is allowed at a time",
                                        "Try `#{@parser.program_name} --help` for more information"].join("\n")
                end

            end

            def option_parser
                OptionParser.new do |op|

                    op.separator ""
                    op.separator "General Options:"
                    
                    op.on("-f", "--file DATABASE_FILE", "The Database File to use") do |db_file|
                        @options.db_file = db_file
                    end

                    op.on("-c", "--config CONFIG_FILE", "The Configuration file to use") do |cfile|
                        @options.config_file = cfile
                    end

                    op.on("-D", "--debug", "Ouput debug information to STDERR") do 
                        @options.debug = true
                    end

                    op.on("--[no-]use-hash-for-url", "Use the password hash algorithm for URL accounts") do |r|
                        @options.use_password_hash_for_url = r
                    end


                    op.separator ""
                    op.separator "Commands, one and only one of these is required:"
                    
                    op.on("-h", "--help") do
                        @options.show_help = true
                    end

                    op.on("-a", "--add ACCOUNT", "Create a new account in keybox") do |account|
                        @actions << [:add, account]
                    end

                    op.on("-d", "--delete ACCOUNT", "Delete the account from keybox") do |account|
                        @actions << [:delete, account]
                    end

                    op.on("-e", "--edit ACCOUNT", "Edit the account in keybox") do |account|
                        @actions << [:edit, account]
                    end

                    op.on("-s", "--show [REGEX]", "Show the given account(s)") do |regex|
                        regex = regex || ".*"
                        @actions << [:show, regex]
                    end

                    op.on("-l", "--list [REGEX]", "List the matching accounts (no argument will list all)") do |regex|
                        regex = regex || ".*"
                        @actions << [:list, regex]
                    end

                    op.on("-m", "--master-password", "Change the master password") do
                        @actions << [:master_password, nil]
                    end

                    op.on("-v", "--version", "Show version information") do
                        @options.show_version = true
                    end

                end
            end

            def default_options
                options = OpenStruct.new
                options.debug                       = 0
                options.show_help                   = false
                options.show_version                = false
                options.config_file                 = Keybox::Application::PasswordSafe::DEFUALT_CONFIG
                options.db_file                     = Keybox::Application::PasswordSafe::DEFUALT_DB
                options.use_password_hash_for_url   = true
                return options
            end

            def merge_configurations
                # get defaults
                # layer on config files
                # then add commandline overrides
            end

            def load_database
                password  = prompt("Password for (#{@options.db_file})", false)
                @db = Keybox::Storage::Container.new(password,@options.db_file)
            end

            #
            # add an account to the database If the account is a URL and
            # use_password_hash_for_url is true then don't us the
            # URLAccountEntry instead of the usual HostAccountEntry
            #
            def add(account) 
                entry = Keybox::HostAccountEntry.new(account, account)

                if @options.use_password_hash_for_url then
                    account_uri = URI.parse(account) 
                    if not account_uri.scheme.nil? then
                        entry = Keybox::URLAccountEntry.new(account,account)
                    end
                end

                gathered = false
                while not gathered do
                    @stdout.puts "Gathering information for entry '#{account}'"

                    entry = fill_entry(entry)

                    # dump the info we have gathered and make sure that
                    # it is the input that the user wants to store.
                    
                    @stdout.puts "-" * 40
                    @stdout.puts entry
                    if prompt_y_n("Is this information correct (y/n) [N] ?") then
                        gathered = true
                    end
                end

                @stdout.puts "Adding #{entry.title} to database"
                @db << entry
            end

            #
            # delete an entry from the database
            #
            def delete(account)
                matches = @db.find_matching_records(account)
                count = 0
                matches.each do |match|
                    @stdout.puts "-" * 40
                    @stdout.puts match
                    if prompt_y_n("Delete this entry (y/n) [N] ?") then
                        @db.delete(match)
                        count += 1
                    end
                end
                @stdout.puts "#{count} records matching '#{account}' deleted."
            end

            #
            # list all the entries in the database.  This doesn't show
            # the password for any of them, just lists the key
            # information about each entry so the user can see what is
            # in the database
            #
            def list(account)
                matches = @db.find_matching_records(account)
                if matches.size > 0 then
                    title_length = matches.collect { |f| f.title.length }.max
                    username_length = matches.collect { |f| f.username.length }.max
                    add_info = "Additional Information"
                    @stdout.puts "#{"Title".center(title_length)} #{"Username".center(username_length)} Additional Information"
                    @stdout.puts "=" * (title_length + username_length + 2 + add_info.length)
                    matches.each do |match|
                        @stdout.puts [match.title.ljust(title_length), match.username.ljust(username_length), match.additional_info].join(" ")
                    end
                    @stdout.puts "#{matches.size} entries listed"
                else
                    @stdout.puts "No records matching '#{account}' were found"
                end
            end

            #
            # output all the information for the accounts matching
            #
            def show(account)
                matches = @db.find_matching_records(account)
                if matches.size > 0 then
                    matches.each do |match|
                        @stdout.puts "=" * 72
                        @stdout.puts match
                    end
                    @stdout.puts "#{matches.size} entries shown"
                else
                    @stdout.puts "No records matching '#{account}' were found"
                end
            end

            def fill_entry(entry)

                # calculate maximum prompt width for pretty output
                max_length = entry.fields.collect { |f| f.length }.max
                max_length += entry.values.collect { |v| v.length }.max

                # now prompt for the entry items
                entry.fields.each do |field|
                    echo = true
                    validate = false
                    default = entry.send(field)
                    p = "#{field} [#{default}]"

                    # we don't echo password prompts and we validate
                    # them
                    if field =~ /^pass/ then
                        echo = false
                        validate = true
                        p = "#{field}"
                    end

                    value = prompt(p,echo,validate,max_length)

                    if value.nil? or value.size == 0 then
                        value = default
                    end
                    entry.send("#{field}=",value)
                end
                return entry
            end

            def run
                error_version_help
                merge_configurations
                load_database
                if @actions.size == 0 then
                    @actions << [:list, ".*"]
                end
                action, param = *@actions.shift
                self.send(action, param)
            end
        end
    end
end
