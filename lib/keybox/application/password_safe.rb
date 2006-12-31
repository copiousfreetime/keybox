require 'keybox/storage'
require 'keybox/application/base'
require 'optparse'
require 'ostruct'
require 'uri'
require 'fileutils'

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
            DEFAULT_DB        = File.join(DEFAULT_DIRECTORY,"database.yaml")
            DEFAULT_CONFIG    = File.join(DEFAULT_DIRECTORY,"config.yaml")

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
                        @parsed_options.db_file = db_file
                    end

                    op.on("-c", "--config CONFIG_FILE", "The Configuration file to use") do |cfile|
                        @parsed_options.config_file = cfile
                    end

                    op.on("-D", "--debug", "Ouput debug information to STDERR") do 
                        @parsed_options.debug = true
                    end

                    op.on("--[no-]use-hash-for-url", "Use the password hash algorithm for URL accounts") do |r|
                        @parsed_options.use_password_hash_for_url = r
                    end


                    op.separator ""
                    op.separator "Commands, one and only one of these is required:"
                    
                    op.on("-h", "--help") do
                        @parsed_options.show_help = true
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
                        @parsed_options.show_version = true
                    end

                end
            end

            def default_options
                options = OpenStruct.new
                options.debug                       = 0
                options.show_help                   = false
                options.show_version                = false
                options.config_file                 = Keybox::Application::PasswordSafe::DEFAULT_CONFIG
                options.db_file                     = Keybox::Application::PasswordSafe::DEFAULT_DB
                options.use_password_hash_for_url   = true
                return options
            end

            # load options from the configuration file, if the file
            # doesn't exist, create it and dump the default options to
            # it.
            #
            # we use the default unless the parsed_options contain a
            # configuration file then we use that one
            def configuration_file_options

                file_path = @parsed_options.config_file || DEFAULT_CONFIG

                # if the file is 0 bytes, then this is illegal and needs
                # to be overwritten.
                if not File.exists?(file_path) or File.size(file_path) == 0 then
                    FileUtils.mkdir_p(File.dirname(file_path))
                    File.open(file_path,"w") do |f|
                        YAML.dump(default_options.marshal_dump,f)
                    end
                end
                options = YAML.load_file(file_path) || Hash.new
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
                    color_puts "Gathering information for entry '#{account}'", :yellow

                    entry = fill_entry(entry)

                    # dump the info we have gathered and make sure that
                    # it is the input that the user wants to store.
                   
                    color_puts "-" * 40, :blue
                    @stdout.puts entry
                    color_puts "-" * 40, :blue
                    if prompt_y_n("Is this information correct (y/n) [N] ?") then
                        gathered = true
                    end
                end

                color_puts "Adding #{entry.title} to database", :green
                @db << entry
            end

            #
            # delete an entry from the database
            #
            def delete(account)
                matches = @db.find(account)
                count = 0
                matches.each do |match|

                    color_puts "-" * 40, :blue
                    @stdout.puts match
                    color_puts "-" * 40, :blue

                    if prompt_y_n("Delete this entry (y/n) [N] ?") then
                        @db.delete(match)
                        count += 1
                    end
                end
                color_puts "#{count} records matching '#{account}' deleted.", :green
            end

            #
            # list all the entries in the database.  This doesn't show
            # the password for any of them, just lists the key
            # information about each entry so the user can see what is
            # in the database
            #
            def list(account)
                matches = @db.find(account)
                if matches.size > 0 then
                    title_length    = matches.collect { |f| f.title.length }.max
                    username_length = matches.collect { |f| f.username.length }.max
                    add_info        = "Additional Information"

                    color_puts "  # #{"Title".ljust(title_length)} #{"Username".ljust(username_length)} #{add_info}", :yellow
                    color_puts "=" * (4 + title_length + username_length + 2 + add_info.length), :blue, false

                    matches.each_with_index do |match,i|
                        color_print sprintf("%3d ", i + 1), :white
                        # toggle colors
                        color = [:cyan, :magenta][i % 2]
                        color_puts [match.title.ljust(title_length), match.username.ljust(username_length), match.additional_info].join(" "), color
                    end
                else
                    color_puts "No matching records were found.", :green
                end
            end

            #
            # output all the information for the accounts matching
            #
            def show(account)
                matches = @db.find(account)
                if matches.size > 0 then
                    matches.each_with_index do |match,i|
                        color_puts "#{sprintf("%3d",i + 1)}. #{match.title}", :yellow
                        max_name_length = match.max_field_length + 1
                        match.each do |name,value|
                            next if name == "title"
                            next if value.length == 0

                            name_out = name.rjust(max_name_length)
                            color_print name_out, :blue
                            color_print " : ", :white

                            if match.private_field?(name) then
                                color_print value, :red
                                color_print " (press any key).", :white
                                junk = get_one_char
                                color_print "\r#{name_out}", :blue
                                color_print " : ", :white
                                color_puts "#{"*" * 20}\e[K", :red
                            else
                                color_puts value, :cyan
                            end
                        end
                        @stdout.puts
                    end
                else
                    color_puts "No matching records were found.", :green
                end
            end

            #
            # Change the master password on the database
            #
            def master_password(ignore_this)
                new_password = prompt("Enter new master password", false, true, 30)
                @db.passphrase = new_password
                @stdout.puts "New master password set."
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
                merge_options
                load_database

                if @actions.size == 0 then
                    @actions << [:list, ".*"]
                end
                action, param = *@actions.shift
                self.send(action, param)

                if @db.modified? then 
                    @db.save
                end
            end
        end
    end
end
