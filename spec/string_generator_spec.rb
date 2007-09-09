require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe Keybox::StringGenerator  do
    before(:each) do
        @generator = Keybox::StringGenerator.new
    end

    it "should not be used alone" do
        lambda { @generator.generate }.should raise_error(Keybox::KeyboxError)
    end

    it "cannot have a min length greater than a max length" do
        @generator.min_length = 90
        lambda { @generator.generate }.should raise_error(Keybox::ValidationError)
    end
    
    it "cannot have a max length less than a min length" do
        @generator.max_length = 2
        lambda { @generator.generate }.should raise_error(Keybox::ValidationError)
    end

    it "initially there are no chunks" do
        @generator.chunks.should have(0).entries
    end
end

describe "chargram generator" do
    before(:each) do 
        @generator = Keybox::CharGramGenerator.new
    end

    it "should have a positive size" do
        @generator.size.should > 26
    end

    it "should emit a string with length > 0" do
        @generator.generate_chunk.size.should > 0
    end

    it "should emit an array " do
        @generator.generate_chunk.should be_instance_of(String)
    end

    it "2 succesive emits should have a common first and last character" do
        one = @generator.generate_chunk
        two = @generator.generate_chunk
        one[-1].should == two[0]
    end

    it "2 calls to generate_chunk should have a string that is 1 less than the 2 chunks" do
        one = @generator.generate_chunk
        two = @generator.generate_chunk
        @generator.to_s.length.should == (one.length + two.length - 1)
    end
end

describe "SymbolSetGenerator" do
    before(:each) do 
        @generator = Keybox::SymbolSetGenerator.new
    end

    it "symbol sets have the right number or characters" do
        Keybox::SymbolSetGenerator::ALL.size.should == 92
    end

    it "generating chunks should produce an array" do
        12.times do 
            @generator.generate_chunk
        end
        @generator.chunks.should have(12).entries
    end

    it "generate should produce a string" do
        @generator.generate.should be_instance_of(String)
        @generator.to_s.size.should > 0
    end

    it "generating chunks can be cleared" do
        @generator.generate
        @generator.clear
        @generator.chunks.should have(0).entries
    end

    it "min and max lengths are respected" do
        @generator.max_length = 25
        @generator.min_length = 25
        @generator.generate.size.should == 25
    end

    it "required sets are utilized" do
        gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
        gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
        p = gen.generate
        gen.required_sets.flatten.uniq.should be_include(p[0].chr)
    end
    it "required sets are merged with symbol sets" do
        gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
        gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
        gen.required_sets.flatten.uniq.each do |c|
            gen.symbols.should be_include(c)
        end
    end

    it "generated passwords autoclear" do
        @generator.generate.should_not == @generator.generate
    end

    it "setting min and max should not affect " do
        g = Keybox::SymbolSetGenerator.new(Keybox::SymbolSet::ALL)
        g.generate.should be_instance_of(String)
    end

end
