require 'mock/ldap/worker/error'

module Mock
  module Ldap
    module Worker
      module Response
        extend Mock::Ldap::Worker::Error

        class Entry

          class IgnoreCaseHash < Hash

            def has_key?(key)
              keys.any? do |k|
                k =~ /^#{key}$/i
              end
            end

            def [](key)
              each_pair do |k, v|
                return v if k =~ /^#{key}$/i
              end

              nil
            end

            def []=(key, value)
              delete(key)
              super
            end

            def delete(key)
              keys.each do |k|
                return super(k) if k =~ /^#{key}$/i
              end
              nil
            end
          end

          class Attributes < IgnoreCaseHash

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
                raise Error::ProtocolError, "extensibleMatch filter rule with dn attributes is not implemented yet."
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
                raise Error::ProtocolError, "Neither mathingRule nor type is not specified in extensibleMatch filter."
              end
            end
          end

          @@base = nil
          @@mutex = Mutex.new

          def initialize(dn, attributes)
            @dn = dn
            @attributes = Attributes[attributes]
            @children = IgnoreCaseHash.new
          end

          attr_reader :dn, :attributes

          def initialize_copy(original)
            @dn = @dn.clone
            @attributes = @attributes.clone
            @children = @children.reduce(IgnoreCaseHash.new) do |acc, val|
              acc[val[0]] = val[1]
              acc
            end
          end

          def base?
            equal?(@@base)
          end

          def self.clear
            @@mutex.synchronize {
              @@base = nil
            }
          end

          def self.add(dn, attributes)
            @@mutex.synchronize {
              if @@base
                raise Error::EntryAlreadyExistsError, "#{dn} is already exists." if @@base.dn == dn
                Entry.new(dn, attributes).add
              else
                @@base = new(dn, attributes)
              end
            }
          end

          def add
            parent.add_child(self)
          rescue Error::NoSuchObjectError
            raise Error::UnwillingToPerformError, "Parent entry is not found."
          end

          def self.modify(dn, operations)
            @@mutex.synchronize {
              raise Error::NoSuchObjectError, "Basedn doesn't exist." unless @@base
              target = @@base.search(dn, :base_object)[0]
              replace = target.clone

              operations.each do |operation|
                replace.modify(operation)
              end

              if target.base?
                @@base = replace
              else
                parent = target.parent
                parent.del_child(target)
                parent.add_child(replace)
              end
            }
          end

          def delete
            raise Error::NotAllowedOnNonLeafError, "#{@dn} is not a leaf entry." unless leaf?
            parent.del_child(self)
          rescue Error::NoSuchObjectError
            raise RuntimeError, "Assertion. Parent entry is not found."
          end

          def modify(operation)
            command = operation[0]
            type, values = operation[1]

            case command
            when :add
              if @attributes.has_key?(type)
                @attributes[type] = @attributes[type] + values
              else
                @attributes[type] = values
              end
            when :delete
              raise Error::NoSuchAttributeError, 'No such attribute is.' unless @attributes.has_key?(type)
              if values.empty?
                @attributes.delete(type)
              else
                values.each do |v|
                  @attributes[type].delete(v) ||(raise Error::NoSuchAttributeError, "Attribute #{type} doesn't have value #{v}.")
                end
                @attributes.delete(type) if @attributes[type].empty?
              end

            when :replace
              if values.empty?
                @attributes.delete(type)
              else
                @attributes[type] = values
              end
            end
          end

          def self.search(dn, scope, attributes, filter)
            @@mutex.synchronize {
              raise Error::NoSuchObjectError, "Basedn doesn't exist." unless @@base
              ret = @@base.search(dn, scope).select { |entry|
                entry.attributes.select(filter)
              }.map { |entry|
                Entry.new(dn, entry.select_attributes(attributes))
              }
              raise Error::NoSuchObjectError, 'No entry is hit.' if ret.empty?
              ret
            }
          end

          def search(dn, scope)
            if dn =~ /^#{@dn}$/i or dn =~ /,#{@dn}$/i
              # Search dn is equals or longer than base dn.
              relative_dns = dn.sub(/,?#{@dn}$/i, '').split(',')
              ret = iter_search(relative_dns, scope)

            elsif @dn =~ /,#{dn}$/i
              # Search dn is shorter than base dn.
              case scope
              when :base_object
                raise Error::NoSuchObjectError, "#{dn} doesn't match to base dn."
              when :single_level
                relative_dns = dn.sub(/,?#{@dn}$/i, '').split(',')
                if relative_dn.length == 1
                  scope = :base_object
                  ret = @children.values.reduce([]) do |acc, child|
                    acc + iter_search(relative_dns, scope)
                  end
                else
                  raise Error::NoSuchObjectError, "#{dn} doesn't match to base dn."
                end
              when :whole_subtree
                relative_dns = []
                ret = iter_search(relative_dns, scope)
              end

            else
              # Search dn doesn't match to base dn.
              raise Error::NoSuchObjectError, "#{dn} doesn't match to base dn."
            end

            raise Error::NoSuchObjectError, "No entry is hit." if ret.empty?
            ret
          end

          def select_attributes(attributes)
            if attributes.empty?
              @attributes.clone

            elsif attributes.include?('*')
              @attributes.clone

            elsif attributes == ['1.1']
              []

            else
              attributes.reduce([]) do |acc, type|
                acc << [type, @attributes[type]] if @attributes.has_key?(type)
                acc
              end
            end
          end

          def self.del(dn)
            @@mutex.synchronize {
              raise Error::NoSuchObjectError, "Basedn doesn't exist." unless @@base
              @@base.search(dn, :base_object)[0].delete
            }
          end

          def leaf?
            @children.empty?
          end

          def parent
            relative_dn, parent_dn = @dn.split(',', 2)
            raise Error::NoSuchObjectError, "Parent entry of #{@dn} is not found." unless parent_dn
            @@base.search(parent_dn, :base_object)[0] || (raise Error::NoSuchObjectError, "Parent entry of #{@dn} is not found.")
          end

          def iter_search(relative_dns, scope)
            if relative_dns.empty?
              case scope
              when :base_object
                [self]
              when :single_level
                @children.values << self
              when :whole_subtree
                @children.values.reduce([self]) do |acc, child|
                  acc + child.iter_search(relative_dns, scope)
                end
              end
            else
              next_dn = relative_dns.pop
              if @children.has_key?(next_dn)
                @children[next_dn].iter_search(relative_dns, scope)
              else
                raise Error::NoSuchObjectError, "No entry is found."
              end
            end
          end

          def add_child(child)
            relative_dn, parent_dn = child.dn.split(',', 2)
            raise RuntimeError, "Assertion. The parent of #{child} is not this entry." unless parent_dn == @dn
            raise Error::EntryAlreadyExistsError, "#{@dn} is already exists." if @children.has_key?(relative_dn)
            @children[relative_dn] = child
          end

          def del_child(child)
            relative_dn, parent_dn = child.dn.split(',', 2)
            raise RuntimeError, "Assertion. The parent of #{child} is not this entry." unless parent_dn == @dn
            raise RuntimeError, "Assertion. Argument child is not a child of this entry." unless @children[relative_dn].equal?(child)
            @children.delete(relative_dn)
          end

          protected :iter_search
        end


      end
    end
  end
end
