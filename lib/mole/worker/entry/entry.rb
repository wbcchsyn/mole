require 'mole/worker/error'
require 'mole/worker/entry/ignore_case_hash'
require 'mole/worker/entry/attributes'

module Mole
  module Worker
    module Entry


      private

      class Entry

        @@base = nil

        def initialize(dn, attributes)
          @dn = dn.freeze
          @attributes = Attributes[attributes]
          @children = IgnoreCaseHash.new
        end

        attr_reader :dn, :attributes, :children

        # Deep copy, but not join itself to DN tree
        def initialize_copy(original)
          @attributes = @attributes.clone
          @children = @children.reduce(IgnoreCaseHash.new) do |acc, val|
            acc[val[0]] = val[1]
            acc
          end
        end

        def base?
          equal?(@@base)
        end

        def self.base=(base)
          @@base = base
        end

        def self.base
          @@base
        end

        def join
          raise Error::EntryAlreadyExistsError, "#{@dn} is already exists." if parent.children.has_key?(rdn)
          parent.children[rdn] = self
        rescue Error::NoSuchObjectError
          raise Error::UnwillingToPerformError, $!.message
        end

        def delete
          if base?
            @@base = nil
          else
            parent.children.delete(rdn) ||
              (raise RuntimeError, "Assertion. #{self} is neither base dn nor child of another.")
          end
        rescue Error::NoSuchObjectError
          raise RuntimeError, "Assertion. Parent entry of #{self} is not found."
        end

        # modify its attribute.
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
            raise Error::NoSuchAttributeError, 'No such attribute #{type} is.' unless @attributes.has_key?(type)
            if values.empty?
              @attributes.delete(type)
            else
              values.each do |v|
                @attributes[type].delete(v) ||
                (raise Error::NoSuchAttributeError, "Attribute #{type} doesn't have value #{v}.")
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

        def search(dn, scope)
          raise RuntimeError, 'Assertion. search method is called from not base dn but from #{self}.' unless base?

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
              if "#{rdn},#{dn}" =~ /^#{@dn}$/i
                # Search dn is parent of Base DN.
                ret = [self]
              else
                raise Error::NoSuchObjectError, "#{dn} doesn't match to base dn."
              end
            when :whole_subtree
              ret = iter_search([], scope)
            end

          else
            # Search dn doesn't match to base dn.
            raise Error::NoSuchObjectError, "#{dn} doesn't match to base dn."
          end

          raise Error::NoSuchObjectError, "No entry is hit under #{dn}." if ret.empty?
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

        # Copy and join itself to new dn including its children recursively.
        def iter_copy(dn)
          new_entry = Entry.new(dn, @attributes.clone).join
          @children.values.each do |child|
            child.iter_copy("#{child.rdn},#{dn}")
          end
          new_entry
        end

        def leaf?
          @children.empty?
        end

        def rdn
          @dn.split(',', 2)[0]
        end

        def parent
          parent_dn = @dn.split(',', 2)[1]
          raise Error::NoSuchObjectError, "Parent entry of #{@dn} is not found." unless parent_dn
          @@base.search(parent_dn, :base_object)[0] ||
            (raise Error::NoSuchObjectError, "Parent entry of #{@dn} is not found.")
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
              raise Error::NoSuchObjectError, "#{next_dn},#{@dn} is not found."
            end
          end
        end

        protected :iter_search, :children

      end


    end
  end
end
