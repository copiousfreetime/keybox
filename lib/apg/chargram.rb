module APG
    class CharacterSource
        def next_sequence
            raise "next_sequence must be implemented"
        end
    end
    class CharGram < CharacterSource
        attr_reader :last_sequence
        def initialize(wordlist)
            @last_sequence = nil
            @source        = Hash.new
            wordlist.each do |word|
                next if word =~ /^#/
                letters = word.split('')
                letter_set = @source[letters.first] ||= Array.new
                letter_set << word
            end
        end

        def size
            s = 0
            @source.each_pair do |l,a|
                s += a.size
            end
            s
        end

        def next_sequence

        end
    end
end
