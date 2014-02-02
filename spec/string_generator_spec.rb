require 'spec_helper'

describe Keybox::StringGenerator  do
  before(:each) do
    @generator = Keybox::StringGenerator.new
  end

  it "is not be used alone" do
    lambda { @generator.generate }.must_raise(Keybox::KeyboxError)
  end

  it "cannot have a min length greater than a max length" do
    @generator.min_length = 90
    lambda { @generator.generate }.must_raise(Keybox::ValidationError)
  end

  it "cannot have a max length less than a min length" do
    @generator.max_length = 2
    lambda { @generator.generate }.must_raise(Keybox::ValidationError)
  end

  it "initially there are no chunks" do
    @generator.chunks.must_be_empty
  end
end

describe "chargram generator" do
  before(:each) do 
    @generator = Keybox::CharGramGenerator.new
  end

  it "has a positive size" do
    @generator.size.must_be( :>, 26 )
  end

  it "emits a string with length > 0" do
    @generator.generate_chunk.size.must_be( :>, 0 )
  end

  it "emits an array " do
    @generator.generate_chunk.must_be_instance_of(String)
  end

  it "2 succesive emits have a common first and last character" do
    one = @generator.generate_chunk
    two = @generator.generate_chunk
    one[-1].must_equal two[0]
  end

  it "2 calls to generate_chunk have a string that is 1 less than the 2 chunks" do
    one = @generator.generate_chunk
    two = @generator.generate_chunk
    @generator.to_s.length.must_equal(one.length + two.length - 1)
  end
end

describe "SymbolSetGenerator" do
  before(:each) do 
    @generator = Keybox::SymbolSetGenerator.new
  end

  it "symbol sets have the right number or characters" do
    Keybox::SymbolSetGenerator::ALL.size.must_equal 92
  end

  it "generating chunks produce an array" do
    12.times do 
      @generator.generate_chunk
    end
    @generator.chunks.size.must_equal 12
  end

  it "generate produces a string" do
    @generator.generate.must_be_instance_of(String)
    @generator.to_s.size.must_be( :>, 0 )
  end

  it "generating chunks can be cleared" do
    @generator.generate
    @generator.clear
    @generator.chunks.must_be_empty
  end

  it "min and max lengths are respected" do
    @generator.max_length = 25
    @generator.min_length = 25
    @generator.generate.size.must_equal 25
  end

  it "required sets are utilized" do
    gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
    gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
    p = gen.generate
    gen.required_sets.flatten.uniq.must_include(p[0].chr)
  end
  it "required sets are merged with symbol sets" do
    gen = Keybox::SymbolSetGenerator.new([Keybox::SymbolSet::NUMERAL_ASCII, Keybox::SymbolSet::LOWER_ASCII])
    gen.required_sets << Keybox::SymbolSet::UPPER_ASCII
    gen.required_sets.flatten.uniq.each do |c|
      gen.symbols.must_include(c)
    end
  end

  it "generated passwords autoclear" do
    @generator.generate.wont_equal @generator.generate
  end

  it "setting min and max has no effect " do
    g = Keybox::SymbolSetGenerator.new(Keybox::SymbolSet::ALL)
    g.generate.must_be_instance_of(String)
  end

end
