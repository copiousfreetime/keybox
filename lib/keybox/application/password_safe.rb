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
            include Keybox::HighLineUtil

            attr_accessor :actions
            attr_reader   :db

            DEFAULT_DIRECTORY    = File.join(home_directory,".keybox")
            DEFAULT_DB           = File.join(DEFAULT_DIRECTORY,"database.yaml")
            DEFAULT_CONFIG       = File.join(DEFAULT_DIRECTORY,"config.yaml")
            DEFAULT_COLOR_SCHEME = :none

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

                    op.on("--color SCHEME","The color scheme to use", "none,dark_bg,light_bg,<other>") do |scheme|
                        @parsed_options.color_scheme = scheme.to_sym
                    end
                          
                    op.on("-D", "--debug", "Ouput debug information to STDERR") do 
                        @parsed_options.debug = true
                    end

                    op.on("--[no-]use-hash-for-url", "Use the password hash algorithm ", "  for URL accounts") do |r|
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
                    
                    op.on("-l", "--list [REGEX]", "List the matching accounts", "  (no argument will list all)") do |regex|
                        regex = regex || ".*"
                        @actions << [:list, regex]
                    end

                    op.on("-m", "--master-password", "Change the master password") do
                        @actions << [:master_password, nil]
                    end
                    
                    op.on("-s", "--show [REGEX]", "Show the given account(s)") do |regex|
                        regex = regex || ".*"
                        @actions << [:show, regex]
                    end

                    op.on("-v", "--version", "Show version information") do
                        @parsed_options.show_version = true
                    end

                    op.separator ""
                    op.separator "Import / Export from other data formats:"
                    
                    op.on("-i", "--import-from-csv FILE", "Import from a CSV file") do |file|
                        @actions << [:import_from_csv, file]
                    end

                    op.on("-x", "--export-to-csv FILE", "Export contents to a CSV file") do |file|
                        @actions << [:export_to_csv, file]
                    end

                end
            end

            def default_options
                if not @default_options then 
                    @default_options                            = OpenStruct.new
                    @default_options.debug                      = 0
                    @default_options.show_help                  = false
                    @default_options.show_version               = false
                    @default_options.config_file                = Keybox::Application::PasswordSafe::DEFAULT_CONFIG
                    @default_options.db_file                    = Keybox::Application::PasswordSafe::DEFAULT_DB
                    @default_options.use_password_hash_for_url  = false
                    @default_options.color_scheme               = Keybox::Application::PasswordSafe::DEFAULT_COLOR_SCHEME
                end
                return @default_options
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
                    determine_color_scheme
                    FileUtils.mkdir_p(File.dirname(file_path))
                    File.open(file_path,"w") do |f|
                        YAML.dump(default_options.marshal_dump,f)
                    end
                end
                options = YAML.load_file(file_path) || Hash.new
            end

            # determine the color scheme to store in the initial creation of the configuration
            # file.  We ask the user which of the color schemes will work best for them.
            def determine_color_scheme
                @default_options.color_scheme = @highline.choose do |menu|
                    menu.layout     = :one_line
                    menu.select_by  = :name
                    menu.header     = nil
                    menu.prompt     = "What color scheme would you like? "
                    menu.choice("none") { :none }
                    menu.choice("dark terminal background") { :dark_bg }
                    menu.choice("light terminal background") { :light_bg }
                end
            end
            
            #
            # load the given color scheme.  If the scheme cannot be
            # found it will default to the +:none+ scheme which has no
            # color
            #
            # The color_scheme file exists either in the application data
            # directory, or in the same directory as the configuration
            # file.
            # 
            # The file name convention for the scheme file is
            # +schemename.color_scheme.yaml+.  So for instance the default
            # +:dark_bg+ color scheme file is named:
            #
            #   dark_bg.color_scheme.yaml
            def load_color_scheme
                if @options.color_scheme != :none then
                    search_directories  = [ Keybox::APP_RESOURCE_DIR, File.dirname(@options.config_file) ]
                    scheme_basename     = "#{@options.color_scheme.to_s}.color_scheme.yaml"
                    scheme_path         = nil
                   
                    # get the path to the file
                    search_directories.each do |sd|
                        if File.exists?(File.join(sd,scheme_basename)) then
                            scheme_path = File.join(sd,scheme_basename)
                            break
                        end
                    end
                  
                    # if we have a file then load it and make sure we have
                    # all the valid labels.
                    if scheme_path then
                        initial_color_scheme = YAML::load(File.read(scheme_path))
                      
                        # make sure that everything is a Symbol and in the
                        # process make sure that all of the required labels
                        # are there.
                        color_scheme = {}
                        initial_color_scheme.each_pair do |label,ansi_seq|
                            color_scheme[label.to_sym] = ansi_seq.collect { |a| a.to_sym }
                        end

                        # validate that all the required color labels exist
                        if (NONE_SCHEME.keys - color_scheme.keys).size == 0 then
                            ::HighLine.color_scheme = ::HighLine::ColorScheme.new(color_scheme)
                        else
                            @options.color_scheme   = :none  
                            ::HighLine.color_scheme = ::HighLine::ColorScheme.new(NONE_SCHEME)

                            @stdout.puts "The color scheme in file '#{scheme_path}' is Invalid"
                            @stdout.puts "It is missing the following items:"

                            (NONE_SCHEME.keys - color_scheme.keys).each do |missing_label|
                                @stdout.puts "\t :#{missing_label}"
                            end

                            @stdout.puts "Not using any color scheme."
                        end

                    else
                        # if we don't have a file then set the color
                        # scheme to :none and we're done
                        @options.color_scheme = :none
                        ::HighLine.color_scheme = ::HighLine::ColorScheme.new(NONE_SCHEME)
                    end
                else
                    ::HighLine.color_scheme = ::HighLine::ColorScheme.new(NONE_SCHEME)
                end
            end

            #
            # load the database from its super secret location
            #
            def load_database
                password = nil
                if not File.exists?(@options.db_file) then
                    hsay 'Creating initial database.', :information
                    password  = prompt("Initial Password for (#{@options.db_file})", :echo => "*", :validate => true)
                else
                    password  = prompt("Password for (#{@options.db_file})", :echo => "*")
                end
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
                    begin 
                        account_uri = URI.parse(account) 
                        if not account_uri.scheme.nil? then
                            entry = Keybox::URLAccountEntry.new(account,account)
                        end
                    rescue ::URI::InvalidURIError => e
                        # just ignore it, we're fine with the Host
                        # Account Entry
                    end

                end
                new_entry = gather_info(entry)
                hsay "Adding #{new_entry.title} to database.", :information
                @db << new_entry
            end

            #
            # Gather all the information for the 
            def gather_info(entry)
                gathered = false
                while not gathered do
                    hsay "Gathering information for entry '#{entry.title}'", :information

                    entry = fill_entry(entry)

                    # dump the info we have gathered and make sure that
                    # it is the input that the user wants to store.
                   
                    hsay "-" * 40, :separator_bar
                    hsay entry, :normal
                    hsay "-" * 40, :separator_bar

                    gathered = hagree "Is this information correct? (y/n)"
                end

                entry
            end

            #
            # delete an entry from the database
            #
            def delete(account)
                matches = @db.find(account)
                count = 0
                matches.each do |match|
                    hsay "-" * 40, :separator_bar
                    hsay match, :normal
                    hsay "-" * 40, :separator_bar

                    if hagree "Delete this entry (y/n) ?" then
                        @db.delete(match)
                        count += 1
                    end
                end
                hsay "#{count} records matching '#{account}' deleted.", :information
            end

            #
            # edit an entry in the database
            #
            def edit(account)
                matches = @db.find(account)
                count = 0
                matches.each do |match|
                    hsay "-" * 40, :separator_bar
                    hsay match, :normal
                    hsay "-" * 40, :separator_bar

                    if hagree "Edit this entry (y/n) ?" then
                        entry = gather_info(match)
                        @db.delete(match)
                        @db << entry
                        count += 1
                        hsay "Entry '#{entry.title}' updated.", :information
                    end
                end
                hsay "#{count} records matching '#{account}' edited.", :information
            end

            #
            # list all the entries in the database.  This doesn't show
            # the password for any of them, just lists the key
            # information about each entry so the user can see what is
            # in the database
            #
            def list(account)
                matches = @db.find(account)
                title           = "Title"
                username        = "Username"
                add_info        = "Additional Information"
                if matches.size > 0 then
                    lengths = {
                        :title              => (matches.collect { |f| f.title.length } << title.length).max,
                        :username           => (matches.collect { |f| f.username.length } << username.length).max,
                        :additional_info    => add_info.length
                    }

                    full_length = lengths.values.inject(0) { |sum,n| sum + n}
                    header = "  # #{"Title".ljust(lengths[:title])}    #{"Username".ljust(lengths[:username])}    #{add_info}"
                    hsay header, :header
                    #  3 spaces for number column + 1 space after and 4 spaces between
                    #  each other column
                    hsay"-" * (header.length), :header_bar

                    matches.each_with_index do |match,i|
                        line_number = sprintf("%3d", i + 1)
                        # toggle colors
                        color = [:even_row, :odd_row][i % 2]
                        columns = []
                        [:title, :username, :additional_info].each do |f|
                            t = match.send(f)
                            t = "-" if t.nil? or t.length == 0 
                            columns << t.ljust(lengths[f])
                        end
                        cdata = columns.join(" " * 4)
                        @highline.say("<%= color('#{line_number}',:line_number) %> <%= color(%Q{#{cdata}},'#{color}') %>")
                    end
                else
                    hsay "No matching records were found.", :information
                end
            end

            #
            # output all the information for the accounts matching
            #
            def show(account)
                matches = @db.find(account)
                if matches.size > 0 then
                    matches.each_with_index do |match,i|
                        hsay "#{sprintf("%3d",i + 1)}. #{match.title}", :header
                        max_name_length = match.max_field_length + 1
                        match.each do |name,value|
                            next if name == "title"
                            next if value.length == 0

                            name_out = name.rjust(max_name_length)
                            @highline.say("<%= color(%Q{#{name_out}}, :name) %> <%= color(':',:separator) %> ")

                            if match.private_field?(name) then
                                @highline.ask(
                                   "<%= color(%Q{#{value}},:private) %> <%= color('(press any key).', :prompt) %> "
                                ) do |q|
                                    q.overwrite = true
                                    q.echo      = false
                                    q.character = true
                                end
                                
                                @highline.say("<%= color(%Q{#{name_out}}, :name) %> <%= color(':',:separator) %> <%= color('#{'*' * 20}', :private) %>")
                            else
                                hsay value, :value
                            end
                        end
                        @stdout.puts
                    end
                else
                    hsay "No matching records were found.", :information
                end
            end

            #
            # Change the master password on the database
            #
            def master_password(ignore_this)
                @db.passphrase = prompt("Enter new master password", :echo => '*', :validate => true, :width => 45) 
                hsay "New master password set.", :information
            end

            #
            # Import data into the database from a CSV file
            #
            def import_from_csv(file)
                entries = Keybox::Convert::CSV.from_file(file)
                entries.each do |entry|
                    @db << entry
                end
                hsay "Imported #{entries.size} records from #{file}.", :information
            end

            #
            # Export data from the database into a CSV file
            def export_to_csv(file)
                Keybox::Convert::CSV.to_file(@db.records, file)
                hsay "Exported #{@db.records.size} records to #{file}.", :information
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

                    # we don't echo private field prompts and we validate
                    # them
                    if entry.private_field?(field) then
                        echo = '*'
                        validate = true
                        p = "#{field}"
                    end

                    value = prompt("#{p}",:echo => echo ,:validate => validate,:width => max_length)

                    if value.nil? or value.size == 0 then
                        value = default
                    end
                    entry.send("#{field}=",value)
                end
                return entry
            end

            def run
                begin
                    error_version_help
                    merge_options
                    load_color_scheme
                    load_database

                    if @actions.size == 0 then
                        @actions << [:list, ".*"]
                    end
                    
                    action, param = *@actions.shift
                    self.send(action, param)
                    
                    if @db.modified? then 
                        hsay "Database modified, saving.", :information
                        @db.save
                    else
                        hsay "Database not modified.", :information
                    end
                rescue SignalException => se
                    @stdout.puts
                    hsay "Interrupted", :error
                    hsay "There may be private information on your screen.", :error
                    hsay "Please close this terminal.", :error
                    exit 1
                rescue StandardError => e
                    hsay "Error: #{e.message}", :error
                    exit 1
                end
            end
        end
    end
end
