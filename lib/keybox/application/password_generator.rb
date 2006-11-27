require 'keybox/string_generator'
require 'optparse'
require 'ostruct'

#----------------------------------------------------------------------
# The Password Generation application
#----------------------------------------------------------------------
module Keybox
    module Application   
        class PasswordGenerator

            ALGORITHMS  = OptionParser::CompletingHash.new
            ALGORITHMS["random"]        = :random
            ALGORITHMS["pronounceable"] = :pronounceable

            SYMBOL_SETS = OptionParser::CompletingHash.new
            Keybox::SymbolSet::MAPPING.keys.each do |k|
                SYMBOL_SETS[k] = k
            end

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
                            @options.algorithm = ALGORITHMS.match(alg)[1]
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
                          " [#{SYMBOL_SETS.keys.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            if SYMBOL_SETS.match(symbol_set).nil? then
                                @error_message = "#{symbol_set} is not one of #{SYMBOL_SETS.keys.join(', ')}}"
                                break
                            end
                        end
                        
                        @options.use_symbols = options_to_symbol_sets(list) unless @error_message
                    end

                    op.on("-rLIST","--require symbol,set,list", Array,
                          "Require passwords have letters from one or more of the following symbol sets:",
                          " [#{SYMBOL_SETS.keys.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            if SYMBOL_SETS.match(symbol_set).nil? then
                                @error_message = "#{symbol_set} is not one of #{SYMBOL_SETS.keys.join(', ')}}"
                                break
                            end
                        end
                        @options.require_symbols = options_to_symbol_sets(list) unless @error_message
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
                    key = SYMBOL_SETS.match(a)[1]
                    sets << Keybox::SymbolSet::MAPPING[key]
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
