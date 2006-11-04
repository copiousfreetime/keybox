require 'keybox'
context "string generator" do
    setup do
        @generator = Keybox::StringGenerator.new
    end
    specify "should not be used alone" do
        lambda { @generator.generate }.should_raise
    end

    specify "cannot have a min length greater than a max length" do
        lambda { @generator.min_length = 90 }.should_raise
    end
    
    specify "cannot have a max length less than a min length" do
        lambda { @generator.max_length = 2}.should_raise
    end

    specify "initially there are no chunks" do
        @generator.chunks.should_have(0).entries
    end
end

context "chargram generator" do
    setup do 
        @generator = Keybox::CharGramGenerator.new
    end

    specify "should have a positive size" do
        @generator.size.should_be > 26
    end

    specify "should emit a string with length > 0" do
        @generator.generate_chunk.size.should_be > 0
    end

    specify "should emit an array " do
        @generator.generate_chunk.should_be_instance_of String
    end

    specify "2 succesive emits should have a common first and last character" do
        one = @generator.generate_chunk
        two = @generator.generate_chunk
        one[-1].should == two[0]
    end

    specify "2 calls to generate_chunk should have a string that is 1 less than the 2 chunks" do
        one = @generator.generate_chunk
        two = @generator.generate_chunk
        @generator.to_s.length.should == (one.length + two.length - 1)
    end
end

context "SymbolSetGenerator" do
    setup do 
        @generator = Keybox::SymbolSetGenerator.new
    end

    specify "symbol sets have the right number or characters" do
        Keybox::SymbolSetGenerator::ALL.size.should == 92
    end

    specify "generating chunks should produce an array" do
        12.times do 
            @generator.generate_chunk
        end
        @generator.chunks.should_have(12).entries
    end

    specify "generate should produce a string" do
        @generator.generate.should_be_instance_of(String)
        @generator.to_s.size.should_be > 0
    end

    specify "generating chunks can be cleared" do
        @generator.generate
        @generator.clear
        @generator.chunks.should_have(0).entries
    end

    specify "min and max lengths are respected" do
        @generator.max_length = 25
        @generator.min_length = 25
        @generator.generate.size.should_be == 25
    end

    specify "required sets are utilized" do
        gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
        gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
        p = gen.generate
        gen.required_sets.flatten.uniq.should_include(p[0].chr)
    end
    specify "required sets are merged with symbol sets" do
        gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
        gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
        gen.required_sets.flatten.uniq.each do |c|
            gen.symbols.should_include(c)
        end
    end
            

end
