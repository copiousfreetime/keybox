require 'keybox/application/base'
require 'keybox/string_generator'
require 'optparse'
require 'ostruct'

#----------------------------------------------------------------------
# The Password Generation application
#----------------------------------------------------------------------
module Keybox
    module Application   
        class PasswordGenerator < Base

            ALGORITHMS  =  { "random"        => :random, 
                             "pronounceable" => :pronounceable }
            SYMBOL_SETS = Keybox::SymbolSet::MAPPING.keys

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
                          "Require passwords to have letters from one or more of the following symbol sets:",
                          " [#{SYMBOL_SETS.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            sym = SYMBOL_SETS.find { |s| s =~ /^#{symbol_set}/ }
                            raise OptionParser::InvalidArgument, ": #{symbol_set} does not match any of #{SYMBOL_SETS.join(', ')}" if sym.nil?
                        end
                        @options.require_symbols = options_to_symbol_sets(list)
                    end

                   op.on("-v", "--version", "Show version information") do
                        @stdout.puts "#{op.program_name}: version #{@options.version.join(".")}"
                        exit 0
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
                exit_or_help
                generator = create_generator
                @options.number_to_generate.times do 
                    @stdout.puts generator.generate
                end
            end
        end
    end
end
