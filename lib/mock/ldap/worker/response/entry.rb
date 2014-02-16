require 'mock/ldap/worker/response/error'

module Mock
  module Ldap
    module Worker
      module Response


        class Entry

          class Attributes < Hash

            def self.[](attributes)
              ret = new

              attributes.each do |attr|
                unless attr.length == 2
                  raise ArgumentError, "invalid number of elements. (#{attr.length} for 2)"
                end
                type = attr[0]
                vals = attr[1]

                ret[type] = vals
              end

              ret
            end

            private :initialize

            def select(filter)
              send(*filter)
            end

            # ignore case of key
            def has_key?(key)
              return true if super

              keys.any? do |k|
                k =~ /^#{key}$/i
              end
            end

            # ignore case of key
            def [](key)
              _val = super
              return _val if _val

              each_pair do |k, v|
                return v if k =~ /^#{key}$/i
              end
              nil
            end

            # ignore case of key
            def []=(key, value)
              keys.each do |k|
                if k =~ /^#{key}$/i
                  delete(k)
                  break
                end
              end

              super
            end

            private

            def and(filters)
              filters.map { |filter|
                select(filter)
              }.all?
            end

            def or(filters)
              filters.map { |filter|
                select(filter)
              }.any?
            end

            def not(filter)
              not select(filter)
            end

            def equality_match(attribute)
              type = attribute[0]
              value = attribute[1]

              return false unless has_key?(type)

              self[type].any? do |v|
                v =~ /^#{value}$/i
              end
            end

            def substrings(substring)
              type = substring[0]

              substring[1].map { |sub|
                position = sub[0]
                value = sub[1]

                return false unless has_key?(type)
                case position
                when :initial
                  self[type].any? do |v| v =~ /^#{value}/i end
                when :any
                  self[type].any? do |v| v =~ /#{value}/i end
                when :final
                  self[type].any? do |v| v =~ /#{value}$/i end
                end
              }.all?
            end

            def greater_or_equal(attribute)
              type = attribute[0]
              value = attribute[1]

              return false unless has_key?(type)

              self[type].any? do |v|
                v.downcase >= value.downcase
              end
            end

            def less_or_equal(attribute)
              type = attribute[0]
              value = attribute[1]

              return false unless has_key?(type)

              self[type].any? do |v|
                v.downcase <= value.downcase
              end
            end

            def present(type)
              has_key?(type)
            end

            def approx_match(attribute)
              # There is no self approximate matching rule,
              # so behave as equality mathcing according to RFC4511 Section 4.5.1.7.6
              equality_match(attribute)
            end

            def extensible_match(attribute)
              matching_rule = attribute[0]
              type = attribute[1]
              match_value = attribute[2]
              dn_attributes = attribute[3] || false

              if dn_attributes
                # TODO Implement extensible_match when dn_attribute is True
                raise RuntimeError, "extensibleMatch filter rule with dn attributes is not implemented yet."
              end

              if matching_rule and type
                select([matching_rule, [type, match_value]])
              elsif (not matching_rule) and type
                equality_match([type, match_value])
              elsif matching_rule and (not type)
                keys.map { |t|
                  select([matching_rule, [t, match_value]])
                }.any?
              else
                raise RuntimeError, "Neither mathingRule nor type is not specified in extensibleMatch filter."
              end
            end
          end

          @@base = nil
          @@mutex = Mutex.new

          def initialize(dn, attributes)
            @dn = dn
            @attributes = Attributes[attributes]
            @children = {}
          end

          attr_reader :dn, :attributes

          def self.clear
            @@mutex.synchronize {
              @@base = nil
            }
          end

          def self.add(dn, attributes)
            @@mutex.synchronize {
              if @@base
                @@base.add(dn, attributes)
              else
                @@base = new(dn, attributes)
              end
            }
          end

          def add(dn, attributes)
            raise RuntimeError, "This method is called only by basedn." unless @@base.equal?(self)

            raise EntryAlreadyExistsError, "dn #{dn} is already exists." if dn == @dn

            raise UnwillingToPerformError, "dn is requested to be subtree of #{@dn}." unless dn.end_with?(",#{@dn}")
            relative_dn = dn.sub(/,#{@dn}/, '').split(',')
            iter_add(relative_dn, attributes)
          end

          def self.search(dn, scope, attributes, filter)
            @@mutex.synchronize {
              raise NoSuchObjectError, "Basedn is not added." unless @@base
              ret = @@base.search(dn, scope, attributes, filter)
              raise NoSuchObjectError, 'No entry is hit.' if ret.empty?
              ret
            }
          end

          def search(dn, scope, attributes, filter)
            if dn =~ /^#{@dn}$/i
              relative_dn = []
            elsif @dn =~ /,#{dn}$/i
              relative_dn = []
            elsif dn =~ /,#{@dn}$/i
              relative_dn = dn.sub(/,#{@dn}$/i, '').split(',')
            else
              raise NoSuchObjectError, "#{dn} doesn't match to basedn."
            end

            iter_search(relative_dn, scope, attributes, filter)
          end

          protected

          def iter_add(relative_dn, attributes)
            raise ArgumentError, "Argument relative_dn is empty." if relative_dn.empty?

            next_dn = relative_dn.pop
            if relative_dn.empty?
              raise EntryAlreadyExistsError, "dn #{next_dn},#{@dn} is already exists." if @children.has_key?(next_dn)
              @children[next_dn] = Entry.new("#{next_dn},#{@dn}", attributes)
            else
              raise UnwillingToPerformError, "dn #{next_dn},#{@dn} doesn't exist." unless @children.has_key?(next_dn)
              @children[next_dn].iter_add(relative_dn, attributes)
            end
          end

          def iter_search(relative_dn, scope, attributes, filter)
            if relative_dn.empty?
              init = @attributes.select(filter) ? [Entry.new(@dn, select_attributes(attributes))] : []

              case scope
              when :base_object
                init
              when :single_level
                @children.values + init
              when :whole_subtree
                @children.values.reduce(init) do |acc, child|
                  acc + child.iter_search(relative_dn, scope, attributes, filter)
                end
              end
            else
              next_dn = relative_dn.pop
              if @children.has_key?(next_dn)
                @children[next_dn].iter_search(relative_dn, scope, attributes, filter)
              else
                raise NoSuchObjectError, "No entry is found."
              end
            end
          end


          private

          def select_attributes(attributes)
            ret = {}
            attributes.each do |type|
              ret[type] = @attributes[type] if @attributes.has_key?(type)
            end
            ret
          end
        end


      end
    end
  end
end
