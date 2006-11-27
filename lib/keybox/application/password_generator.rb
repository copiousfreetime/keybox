require 'keybox/string_generator'
require 'optparse'
require 'ostruct'

#----------------------------------------------------------------------
# The Password Generation application
#----------------------------------------------------------------------
module Keybox
    module Application   
        class PasswordGenerator

            ALGORITHMS  =  { "random"        => :random, 
                             "pronounceable" => :pronounceable }
            SYMBOL_SETS = Keybox::SymbolSet::MAPPING.keys

            attr_reader   :options
            attr_reader   :error_message

            # these are here for testing instrumentation
            attr_accessor :stdout
            attr_accessor :stderr

            def initialize(argv = [])
                # make sure we have an empty array, we could be passed
                # nil explicitly
                argv ||= []

                # for testing instrumentation
                @stdout = $stdout
                @stderr = $stderr

                @options        = self.default_options
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

                    op.on("-aALGORITHM", "--algorithm ALGORITHM", ALGORITHMS.keys,
                          "Select the algorithm for password generation",
                          " #{ALGORITHMS.keys.join(', ')}") do |alg|
                           key = ALGORITHMS.keys.find { |x| x =~ /^#{alg}/ }
                            @options.algorithm = ALGORITHMS[key]
                    end

                    op.on("-h", "--help") do 
                        @options.show_help = true
                    end

                    op.on("-mLENGTH ", "--min-length LENGTH", Integer,
                           "Minimum LENGTH of the new password in letters") do |len|
                        @options.min_length = len
                    end
                    
                    op.on("-xLENGTH ", "--max-length LENGTH", Integer,
                           "Maximum LENGTH of the new password in letters") do |len|
                        @options.max_length = len
                    end
                    
                    op.on("-nNUMER", "--number NUMBER", Integer,
                          "Generate NUMBER of passwords (default 6)") do |n|
                        @options.number_to_generate = n
                    end

                    op.on("-uLIST", "--use symbol,set,list", Array,
                          "Use only one ore more of the following symbol sets:",
                          " [#{SYMBOL_SETS.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            sym = SYMBOL_SETS.find { |s| s =~ /^#{symbol_set}/ }
                            raise OptionParser::InvalidArgument, ": #{symbol_set} does not match any of #{SYMBOL_SETS.join(', ')}" if sym.nil?
                        end
                        
                        @options.use_symbols = options_to_symbol_sets(list)
                    end

                    op.on("-rLIST","--require symbol,set,list", Array,
                          "Require passwords have letters from one or more of the following symbol sets:",
                          " [#{SYMBOL_SETS.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            sym = SYMBOL_SETS.find { |s| s =~ /^#{symbol_set}/ }
                            raise OptionParser::InvalidArgument, ": #{symbol_set} does not match any of #{SYMBOL_SETS.join(', ')}" if sym.nil?
                        end
                        @options.require_symbols = options_to_symbol_sets(list)
                    end
                end
            end
            
            def default_options
                options = OpenStruct.new
                options.debug               = 0
                options.version             = Keybox::VERSION
                options.show_help           = false
                options.algorithm           = :random
                options.number_to_generate  = 6
                options.min_length          = 8
                options.max_length          = 10
                options.use_symbols         = options_to_symbol_sets(["all"])
                options.require_symbols     = options_to_symbol_sets([])
                return options
            end

            def options_to_symbol_sets(args)
                sets = []
                args.each do |a|
                    sym = SYMBOL_SETS.find { |s| s =~ /^#{a}/ }
                    sets << Keybox::SymbolSet::MAPPING[sym]
                end
                sets
            end

            def create_generator
                case @options.algorithm
                when :pronounceable
                    generator = Keybox::CharGramGenerator.new
                when :random
                    generator = Keybox::SymbolSetGenerator.new(@options.use_symbols)
                    @options.require_symbols.each do |req|
                        generator.required_sets << req
                    end
                end
                
                generator.max_length = [@options.min_length,@options.max_length].max
                generator.min_length = [@options.min_length,@options.max_length].min

                # record what we set the generator to
                @options.max_length = generator.max_length
                @options.min_length = generator.min_length

                return generator
            end

            def run
                if @error_message then
                    @stderr.puts @error_message 
                    exit 1
                elsif @options.show_help then
                    @stdout.puts @parser
                    exit 0
                else
                    generator = create_generator
                    @options.number_to_generate.times do 
                        @stdout.puts generator.generate
                    end
                end
            end
        end
    end
end
