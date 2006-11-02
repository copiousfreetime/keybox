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
        def initialize(wordlist)
            @last_sequence = nil
            @source        = Hash.new
            wordlist.each do |word|
                next if word =~ /^#/
                letters = word.split('')
                letter_set = @source[letters.first] ||= Array.new
                letter_set << word
            end
            @randomizer = Keybox::Randomizer.new
        end

        def size
            s = 0
            @source.each_pair do |l,a|
                s += a.size
            end
            s
        end

        def emit
            choose_from = Keybox::Ra
            if @last_sequence then


        end
    end
end
