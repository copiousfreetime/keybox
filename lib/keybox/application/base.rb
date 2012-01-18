require 'optparse'
require 'ostruct'
require 'keybox/highline_util'

#------------------------------------------------------------------------
# Base class for applications in keybox
#
# All of they keybox base applications are instantiated and then the
# .run method is called on the instance.  In otherwards
#
# kapp = Keybox::Application::KeyApp.new(ARGV)
# kapp.run
# 
#------------------------------------------------------------------------

module Keybox
    module Application
        class Base
            # all applications have options and an error message
            attr_accessor :options
            attr_accessor :parsed_options
            attr_accessor :error_message

            # these allow for testing instrumentation
            attr_reader :stdout
            attr_reader :stderr
            attr_reader :stdin
            attr_reader :highline

            class << self
                # thank you Jamis - from Capistrano
                def home_directory # :nodoc:
                    ENV["HOME"] ||
                        (ENV["HOMEPATH"] && "#{ENV["HOMEDRIVE"]}#{ENV["HOMEPATH"]}") ||
                        "/"
                end
            end

            def initialize(argv = [])
                # make sure we have an empty array, we could be
                # initially passed nil explicitly
                argv ||= []

                # setup default io streams
                set_io

                @options        = self.default_options
                @parsed_options = OpenStruct.new
                @parser         = self.option_parser
                @error_message  = nil

                begin
                    @parser.parse!(argv)
                rescue OptionParser::ParseError => pe
                    msg = ["#{@parser.program_name}: #{pe}",
                            "Try `#{@parser.program_name} --help` for more information"]
                    @error_message = msg.join("\n")
                end
            end

            #
            # Allow the IO to be reset.  This is generally just for
            # testing instrumentation, but it may be useful for
            # something else too.
            #
            def set_io(stdin = $stdin,stdout = $stdout,stderr = $stderr)
                # for testing instrumentation
                @stdin    = stdin
                @stdout   = stdout
                @stderr   = stderr
                
                # Instance of HighLine for the colorization of output
                @highline = ::HighLine.new(@stdin,@stdout)
            end

            def option_parser
                OptionParser.new do |op|
                    op.separator ""
                    op.separator "Options:"

                    op.on("-h", "--help") do
                        @parsed_options.show_help = true
                    end

                    op.on("-v", "--version", "Show version information") do
                        @parsed_options.show_version = true
                    end 
                end
            end

            def default_options
                if not defined? @default_options then
                    @default_options = OpenStruct.new
                    @default_options.debug           = 0
                    @default_options.show_version    = false
                    @default_options.show_help       = false
                end
                return @default_options
            end

            def configuration_file_options
                Hash.new
            end

            # load the default options, layer on the file options and
            # then merge in the command line options
            def merge_options
                options = default_options.marshal_dump
                self.configuration_file_options.each_pair do |key,value|
                    options[key] = value
                end

                @parsed_options.marshal_dump.each_pair do |key,value|
                    options[key] = value
                end

                @options = OpenStruct.new(options)
            end

 
            def error_version_help
                if @error_message then
                    @stderr.puts @error_message
                    exit 1
                elsif @parsed_options.show_version then
                    @highline.say "#{@parser.program_name}: version #{Keybox::VERSION}"
                    exit 0
                elsif @parsed_options.show_help then
                    @highline.say @parser.to_s
                    exit 0
                end
            end

            def run 
                error_version_help
                @highline.say "Keybox Base Application.  Doing nothing but output this line."
            end

        end
    end
end
