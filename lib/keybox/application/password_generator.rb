require 'keybox/string_generator'
require 'optparse'
require 'ostruct'

#----------------------------------------------------------------------
# The Password Generation application
#----------------------------------------------------------------------
module Keybox
    module Application   
        class PasswordGenerator

            ALGORITHM_LIST  = %w(random pronouncable)
            SYMBOL_SET_LIST = Keybox::SymbolSet::MAPPING.keys

            attr_reader :options

            def initialize(argv)
                @options = self.default_options
                @parser  = self.option_parser
                begin
                    @parser.parse!(argv)
                rescue OptionParser::ParseError => pe
                    puts "#{@parser.program_name}: #{pe}"
                    puts "Try `#{@parser.program_name} --help` for more information"
                    exit 1
                end 
            end

            def option_parser
                OptionParser.new do |op|
                    op.separator ""

                    op.separator "Options:"

                    op.on("-aALGORITHM", "--algorithm ALGORITHM", ALGORITHM_LIST,
                          "Select the algorithm for password generation",
                          " #{ALGORITHM_LIST.join(', ')}") do |alg|
                            @options.algorithm = alg.to_sym
                    end

                    op.on("-h", "--help") do 
                        puts op
                        exit 0
                    end

                    op.on("-mLENGTH ", "--min-length LENGTH", Integer,
                           "Minimum LENGTH of the new password in letters") do |len|
                        @options.min_length = len
                    end
                    
                    op.on("-xLENGTH ", "--max-length LENGTH", Integer,
                           "Maximum LENGTH of the new password in letters") do |len|
                        @options.max_length = len
                    end
                    
                    op.on("-nNUMER", "--number NUMBER", :REQUIRED, Integer,
                          "Generate NUMBER of passwords (default 6)") do |n|
                        @options.number = n
                    end

                    op.on("-uLIST", "--use symbol,set,list", Array,
                          "Use only one ore more of the following symbol sets:",
                          " [#{SYMBOL_SET_LIST.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            if not SYMBOL_SET_LIST.include?(symbol_set) then
                                raise OptionParser::InvalidArgument, "#{symbol_set} is not one of #{SYMBOL_SET_LIST.join(', ')}}" 
                            end
                        end
                        @options.use_symbols = options_to_symbol_sets(list)
                    end

                    op.on("-rLIST","--require symbol,set,list", Array,
                          "Require passwords have letters from one or more of the following symbol sets:",
                          " [#{SYMBOL_SET_LIST.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            if not SYMBOL_SET_LIST.include?(symbol_set) then
                                raise OptionParser::InvalidArgument, "#{symbol_set} is not one of #{SYMBOL_SET_LIST.join(', ')}}" 
                            end
                        end
                        @options.require_symbols = options_to_symbol_sets(list)
                    end
                end
            end
            
            def default_options
                options = OpenStruct.new
                options.debug               = 0
                options.version             = Keybox::VERSION
                options.help                = false
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
                    sets << Keybox::SymbolSet::MAPPING[a]
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
                
                generator.max_length = [@options.max_length, @options.min_length].max
                generator.min_length = [@options.max_length, @options.min_length].min

                return generator
            end

            def run
                generator = create_generator
                @options.number_to_generate.times do 
                    puts generator.generate
                end
            end
        end
    end
end
