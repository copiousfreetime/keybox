require 'keybox/randomizer'

module Keybox

    # base class for string generation.  A string generator can be
    # called serially to generate a new string in chunks, or all at once
    # to generate one of a certain size.
    class StringGenerator
        attr_accessor :chunks
        attr_reader :min_length
        attr_reader :max_length

        def initialize
            @chunks = Array.new
            @min_length = 8
            @max_length = 10
            @randomizer = Keybox::Randomizer.new
        end

        def generate
            generate_chunk until valid?
            self.to_s
        end

        def clear
            @chunks.clear
        end

        def to_s
            @chunks.join('')[0...@max_length]
        end

        def valid?
            @chunks.join('').size > @min_length 
        end

        def max_length=(m)
            raise "max_length cannot be less than min length (#{min_length})" if m < min_length
            @max_length = m
        end

        def min_length=(m)
            raise "min_length cannot be greater than max length (#{max_length})" if m > max_length
            @min_length = m
        end

        def generate_chunk
            raise "generate_chunk Not Implemented"
        end

    end

    # CharGramGenerator emits a sequence that is a CharGram of length N.
    # The ngrams can be the default ones that ship with keybox or an
    # array passed in.
    class CharGramGenerator < StringGenerator
        attr_reader :pool


        def initialize(chargram_list = nil)
            super()
            wordlist = chargram_list || load_default_chargram_list
            @pool          = Hash.new
            wordlist.each do |word|
                letters = word.split('')
                letter_set = @pool[letters.first] ||= Array.new
                letter_set << word
            end
        end

        def size
            @pool.inject(0) { |sum,h| sum + h[1].size }
        end

        # return a random chargram from the pool indidcated by the last
        # character of the last emitted item
        def generate_chunk
            pool_key = ""
            if @chunks.size > 0 then
                pool_key = @chunks.pop
            else
                pool_key = @randomizer.pick_one_from(@pool.keys)
            end
            new_chunk = @randomizer.pick_one_from(@pool[pool_key])
            @chunks.concat(new_chunk.split(//))
            new_chunk
        end

        private

        def load_default_chargram_list
            list = []
            File.open(File.join(Keybox::APP_RESOURCE_DIR,"chargrams.txt")) do |f|
                f.each_line do |line|
                    next if line =~ /^#/
                    list << line.rstrip
                end
            end
            list
        end
    end

    module SymbolSet
        LOWER_ASCII   = ("a".."z").to_a
        UPPER_ASCII   = ("A".."Z").to_a
        NUMERAL_ASCII = ("0".."9").to_a
        SPECIAL_ASCII = ("!".."/").to_a + (":".."@").to_a + %w( [ ] ^ _ { } | ~ )
        
        ALL = LOWER_ASCII + UPPER_ASCII + NUMERAL_ASCII + SPECIAL_ASCII
    end

    # 
    # SymbolSetGenerator uses symbol sets and emits a single character
    # from the aggregated symobl sets that the instance is wrapping.
    #
    # That is When a SymbolSetGenerator is instantiated, it can take a
    # list of symbol sets (a-z, A-Z, 0-9) etc as parameters.  Those sets
    # are merged and when 'emit' is called a string of length 1 is
    # returned from the aggregated symbols
    #
    class SymbolSetGenerator < StringGenerator
        include SymbolSet

        attr_accessor :required_sets
        
        def initialize(set = ALL)
            super()
            @symbols = set.flatten.uniq
            @required_sets = []
        end

        # every time we access the symbols set we need to make sure that
        # the required symbols are a part of it, and if they aren't then
        # make sure they are.
        def symbols
            if @required_sets.size > 0 then
                if not @symbols.include?(@required_sets.first[0]) then
                    @symbols << @required_sets
                    @symbols.flatten!
                    @symbols.uniq!
                end
            end
            @symbols 
        end

        def required_generated?
            result = true
            @required_sets.each do |set|
                set_found = false
                @chunks.each do |chunk|
                    if set.include?(chunk) then
                        set_found = true
                        break
                    end
                end
                result = (result and set_found)
            end
            return result
        end

        # we force generation of the required sets at the beginning the
        # first time we are called.
        def generate_chunk
            chunk = ""
            if required_generated? then
                @chunks << @randomizer.pick_one_from(symbols)
                chunk = @chunks.last
            else
                req = generate_required
                @chunks.concat(req)
                chunk = req.join('')
            end
            return chunk
        end

        # valid for the symbol set generator means the parent classes
        # validity and that we have in the 
        def valid?
            super and required_generated?
        end

        private

        # generate symbols from the required sets 
        def generate_required
            req = []
            required_sets.each do |set|
                req << @randomizer.pick_one_from(set)
            end
            return req
        end
    end
end
