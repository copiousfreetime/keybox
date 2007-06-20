module Keybox
    module Storage

        ## 
        # Record is very similar to an OStruct but it keeps track of the
        # last access, creation and modification times of the object.
        # Each Record also has a UUID for unique identification.
        #
        #   rec = Keybox::Storage::Record.new
        #
        #   rec.modified?                   # => false
        #   rec.some_field = "some value"   # => "some value"
        #   rec.modified?                   # => true
        #   rec.modification_time           # => Time
        #   rec.data_members                # => { :some_field => "some value" }
        #   rec.uuid.to_s                   # => "4b25074d-d3c5-23cd-bf9f-e28d8c8d453d"
        #
        # The +creation_time+, +modification_time+ and +last_access_time+ of
        # each field in the Record is recorded.
        #
        # The UUID is create when the class is instantiated.
        #
        class Record 

            attr_reader :creation_time
            attr_reader :modification_time
            attr_reader :last_access_time
            attr_reader :uuid
            attr_reader :data_members

            PROTECTED_METHODS = [ :creation_time=, :modification_time=, :last_access_time=, 
                                  :uuid=, :data_members=, :modified, ]
            def initialize
                @creation_time     = Time.now
                @modification_time = @creation_time.dup
                @last_access_time  = @creation_time.dup
                @uuid              = Keybox::UUID.new
                @data_members      = Hash.new
                @modified          = false
            end

            def modified?
                # since this class can be loaded from a YAML file and
                # modified is not stored in the serialized format, if
                # @modified is not initialized, initialize it.
                if not instance_variables.include?("@modified") then
                    @modified = false
                end
                @modified
            end

            # an array of the data member names
            def data_member_names
                @data_members.keys.collect { |n| n.to_s }
            end


            # this is here so that after this class has been serialized
            # to a file the container can mark it as clean.  The class
            # should take care of marking itself dirty.
            def modified=(value)
                @modified = value
            end

            def method_missing(method_id, *args)
                method_name = method_id.id2name
                member_sym  = method_name.gsub(/=/,'').to_sym

                # guard against assigning to the time data members and
                # the data_members element
                if PROTECTED_METHODS.include?(method_id) then
                    raise NoMethodError, "invalid method #{method_name} for #{self.class.name}", caller(1)
                end

                # if the method ends with '=' and has a single argument,
                # then convert the name to the appropriate data member
                # and store the argument in the hash. 
                if method_name[-1].chr == "=" then
                    raise ArgumentError, "'#{method_name}' requires one and only one argument", caller(1) unless args.size == 1
                    @data_members[member_sym] = args[0]
                    @modified = true
                    @modification_time        = Time.now
                    @last_access_time         = @modification_time.dup
                elsif args.size == 0 then
                    @last_access_time = Time.now
                    @data_members[member_sym]
                else
                    raise NoMethodError, "undefined method #{method_name} for #{self.class.name}", caller(1)
                end
            end

            def to_yaml_properties
                %w{ @creation_time @modification_time @last_access_time @data_members @uuid }
            end

            def ==(other)
                self.eql?(other)
            end

            def eql?(other)
                if other.kind_of?(Keybox::Storage::Record) then
                    self.uuid == other.uuid
                else
                    self.uuid == other
                end
            end
        end
    end
end
