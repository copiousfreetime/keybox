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
                          "Select the algorithm for password ", 
                          "  generation (#{ALGORITHMS.keys.join(', ')})") do |alg|
                           key = ALGORITHMS.keys.find { |x| x =~ /^#{alg}/ }
                            @parsed_options.algorithm = ALGORITHMS[key]
                    end

                    op.on("-h", "--help") do 
                        @parsed_options.show_help = true
                    end

                    op.on("-mLENGTH ", "--min-length LENGTH", Integer,
                           "Minimum LENGTH of the new password","  in letters") do |len|
                        @parsed_options.min_length = len
                    end
                    
                    op.on("-xLENGTH ", "--max-length LENGTH", Integer,
                           "Maximum LENGTH of the new password","  in letters") do |len|
                        @parsed_options.max_length = len
                    end
                    
                    op.on("-nNUMER", "--number NUMBER", Integer,
                          "Generate NUMBER of passwords (default 6)") do |n|
                        @parsed_options.number_to_generate = n
                    end

                    op.on("-uLIST", "--use symbol,set,list", Array,
                          "Use only one ore more of the following", "  symbol sets:",
                          "  [#{SYMBOL_SETS.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            sym = SYMBOL_SETS.find { |s| s =~ /^#{symbol_set}/ }
                            raise OptionParser::InvalidArgument, ": #{symbol_set} does not match any of #{SYMBOL_SETS.join(', ')}" if sym.nil?
                        end
                        
                        @parsed_options.use_symbols = options_to_symbol_sets(list)
                    end

                    op.on("-rLIST","--require symbol,set,list", Array,
                          "Require passwords to have letters from", "  one or more of the following",
                          "  symbol sets:", "  [#{SYMBOL_SETS.join(', ')}]") do |list|
                        list.each do |symbol_set|
                            sym = SYMBOL_SETS.find { |s| s =~ /^#{symbol_set}/ }
                            raise OptionParser::InvalidArgument, ": #{symbol_set} does not match any of #{SYMBOL_SETS.join(', ')}" if sym.nil?
                        end
                        @parsed_options.require_symbols = options_to_symbol_sets(list)
                    end

                    op.on("-v", "--version", "Show version information") do
                        @parsed_options.show_version = true
                    end 

                end
            end
            
            def default_options
                if not @default_options then
                    @default_options = OpenStruct.new
                    @default_options.debug               = 0
                    @default_options.show_version        = false
                    @default_options.show_help           = false
                    @default_options.algorithm           = :random
                    @default_options.number_to_generate  = 6
                    @default_options.min_length          = 8
                    @default_options.max_length          = 10
                    @default_options.use_symbols         = options_to_symbol_sets(["all"])
                    @default_options.require_symbols     = options_to_symbol_sets([])
                end
                return @default_options
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
                error_version_help
                merge_options
                generator = create_generator
                @options.number_to_generate.times do 
                    @stdout.puts generator.generate
                end
            end
        end
    end
end
