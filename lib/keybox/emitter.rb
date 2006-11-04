module Keybox

    # base class for a character emitter.  A character emitter returns
    # an array of characters with length greater than or equal to 1 with
    # each call to emit
    class CharacterEmitter
        def emit
            raise "emit must be implemented"
        end
    end

    # CharGramEmitter emits a sequence that is a CharGram of length N.
    # The ngrams can be loaded from a file or an array
    class CharGramEmitter < CharacterEmitter
        attr_reader :last_emit
        attr_reader :pool

        def initialize(chargram_list = nil)
            wordlist = chargram_list || load_default_chargram_list
            @pool          = Hash.new
            wordlist.each do |word|
                letters = word.split('')
                letter_set = @pool[letters.first] ||= Array.new
                letter_set << word
            end
            @randomizer = Keybox::Randomizer.new

            # initialize the last_emit with a random key from @pool 
            @last_emit = @randomizer.pick_one_from(@pool.keys)
        end

        def size
            @pool.inject(0) { |sum,h| sum + h[1].size }
        end

        # return a random chargram from the pool indidcated by the last
        # character of the last emitted item
        def emit
            @last_emit = @randomizer.pick_one_from(@pool[@last_emit[-1].chr])
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

    #
    # 
end
