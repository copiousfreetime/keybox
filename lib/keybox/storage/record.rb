module Keybox
    module Storage

        # 
        # Record is very similar to an OStruct but it keeps track of the
        # last access, creation and modification times of the object
        #
        class Record 

            attr_reader :creation_time
            attr_reader :modification_time
            attr_reader :last_access_time
            attr_reader :data_members

            def initialize
                @creation_time     = Time.now
                @modification_time = @creation_time.dup
                @last_access_time  = @creation_time.dup
                @data_members      = Hash.new
            end

            def method_missing(method_id, *args)
                method_name = method_id.id2name
                
                member_sym = method_name.gsub(/=/,'').to_sym

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
                    @modification_time        = Time.now
                    @last_access_time         = @modification_time.dup
                    @data_members[member_sym]  = args[0]
                elsif args.size == 0 then

                    @last_access_time = Time.now
                    @data_members[member_sym]
                else
                    raise NoMethodError, "undefined method #{method_name} for #{self.class.name}", caller(1)
                end
            end

            def to_yaml_properties
                %w{ @creation_time @modification_time @last_access_time @data_members }
            end
        end
    end
end
