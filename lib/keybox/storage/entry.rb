module Keybox
    module Storage

        # 
        # Entry is very similar to an OStruct but it keeps track of the
        # last access, creation and modification times of the object
        #
        class Entry 

            attr_reader :creation_time
            attr_reader :modification_time
            attr_reader :last_access_time

            def initialize
                @creation_time     = Time.now
                @modification_time = @creation_time.dup
                @last_access_time  = @creation_time.dup
                @data_members      = Hash.new
            end

            def method_missing(method_id, *args)
                method_name = method_id.id2name

                # guard against assigning to the time data members and
                # the data_members element
                if [:creation_time=, :modification_time=, :last_access_time=, :data_members, :data_members=].include?(method_id) then
                    raise NoMethodError, "invalid method #{method_name} for #{self.class.name}", caller(1)
                end

                # if the method ends with '=' and has a single argument,
                # then convert the name to the appropriate data member
                # and store the argument in the hash. 
                if method_name[-1].chr == "=" then
                    raise ArgumentError, "'#{method_name}' requires one and only one argument", caller(1) unless args.size == 1
                    self.new_data_member(method_name.chop)
                    self.send(method_name,*args)
                elsif args.size == 0 then
                    self.new_data_member(method_name)
                    self.send(method_name)
                else
                    raise NoMethodError, "undefined method #{method_name} for #{self.class.name}", caller(1)
                end
            end

            #
            # create accessor methods for the data member, recording the
            # access and modified times as appropriate for the reader
            # and writer calls
            # 
            def new_data_member(member_name)
                member_sym = member_name.to_sym
                set_member_sym = "#{member_name}=".to_sym

                # define an accessor method that records the time of the
                # access
                self.class.send(:define_method,member_sym) do 
                    @last_access_time = Time.now
                    @data_members[member_sym]
                end

                # define an assignment method that records the time of
                # the assignment
                self.class.send(:define_method,set_member_sym) do |val|
                    @data_members[member_sym] = val
                    @modification_time        = Time.now
                    @last_access_time         = @modification_time.dup
                end
            end

        end
    end
end
