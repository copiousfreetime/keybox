require 'keybox/storage'
context 'a storage container' do
    specify 'should have a uuid' do
        s = Keybox::Storage::Container.new
        s.uuid.should_satisfy { |uuid| uuid.to_s.length == 36 }
    end
end
