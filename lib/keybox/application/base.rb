require 'optparse'
require 'ostruct'

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
            attr_accessor :stdout
            attr_accessor :stderr
            attr_accessor :stdin

            def initialize(argv = [])
                # make sure we have an empty array, we could be
                # initially passed nil explicitly
                argv ||= []

                # for testing instrumentation
                @stdin  = $stdin
                @stdout = $stdout
                @stderr = $stderr

                @options        = self.default_options
                @parsed_options = self.default_options
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
                options = OpenStruct.new
                options.debug           = 0
                options.show_version    = false
                options.show_help       = false
                return options
            end

            def configuration_file_options
                Hash.new
            end

            # load the default options, layer on the file options and
            # then merge in the command line options
            def merge_options
                options = default_options.marshal_dump
                configuration_file_options.each_pair do |key,value|
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
                    @stdout.puts "#{@parser.program_name}: version #{Keybox::VERSION.join(".")}"
                    exit 0
                elsif @parsed_options.show_help then
                    @stdout.puts @parser
                    exit 0
                end
            end

            def run 
                error_version_help
                @stdout.puts "Keybox Base Application.  Doing nothing but output this line."
            end
        end
    end
end