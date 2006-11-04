require 'keybox'
context "chargram emitter" do
    setup do 
        @emitter = Keybox::CharGramEmitter.new
    end

    specify "should have a positive size" do
        @emitter.size.should_be > 26
    end

    specify "should emit a string with length > 0" do
        @emitter.emit.size.should_be > 0
    end

    specify "2 succesive emits should have a common first and last character" do
        one = @emitter.emit
        two = @emitter.emit
        one[-1].should == two[0]
    end
end
