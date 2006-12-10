require 'keybox/storage'
require 'keybox/application/base'
require 'optparse'
require 'ostruct'

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

                    op.on("-s", "--show ACCOUNT", "Show the given account(s)") do |account|
                        @actions << [:show, account]
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
                # 
            end

            def load_database
                password  = prompt("Password for (#{@options.db_file}): ", false)
                @db = Keybox::Storage::Container.new(password,@options.db_file)
            end

            def run
                error_version_help
                merge_config
                load_database
                @stdout.puts "Keybox application, nothing here yet"
            end
        end
    end
end
