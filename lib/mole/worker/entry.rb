require 'mole/worker/error'
require 'mole/worker/entry/entry'


module Mole
  module Worker
    module Entry

      Lock = Mutex.new

      def clear
        Lock.synchronize {
          Entry.base = nil
        }
      end

      def add(dn, attributes)
        Lock.synchronize {
          if Entry.base
            raise Error::EntryAlreadyExistsError, "#{dn} is already exists." if Entry.base.dn == dn
            Entry.new(dn, attributes).join
          else
            Entry.base = Entry.new(dn, attributes)
          end
        }
      end

      def modify(dn, operations)
        Lock.synchronize {
          raise Error::NoSuchObjectError, "Basedn doesn't exist." unless Entry.base
          target = Entry.base.search(dn, :base_object)[0]
          replace = target.clone

          operations.each do |operation|
            replace.modify(operation)
          end

          if target.base?
            Entry.base = replace
          else
            target.delete
            replace.join
          end
        }
      end

      def search(dn, scope, attributes, filter)
        Lock.synchronize {
          raise Error::NoSuchObjectError, "Basedn doesn't exist." unless Entry.base
          ret = Entry.base.search(dn, scope).select { |entry|
            entry.attributes.select(filter)
          }.map { |entry|
            Entry.new(entry.dn, entry.select_attributes(attributes))
          }
          raise Error::NoSuchObjectError, 'No entry is hit.' if ret.empty?
          ret
        }
      end

      def del(dn)
        Lock.synchronize {
          raise Error::NoSuchObjectError, "Basedn doesn't exist." unless Entry.base
          entry = Entry.base.search(dn, :base_object)[0]
          raise Error::NotAllowedOnNonLeafError, "#{dn} is not a leaf entry." unless entry.leaf?
          entry.delete
        }
      end

      def modify_dn(old_dn, new_rdn, delete_old, new_parent_dn)
        Lock.synchronize {
          old_entry = Entry.base.search(old_dn, :base_object)[0]

          # Make it a rule not to move Base DN following OpenLDAP.
          raise Error::UnwillingToPerformError, "#{old_dn} is Base DN." if old_entry.base?

          new_parent_dn = old_entry.dn unless new_parent_dn

          old_entry.iter_copy("#{new_rdn},#{new_parent_dn}")
          old_entry.delete if delete_old
        }
      end


      module_function :clear, :add, :modify, :search, :del, :modify_dn

    end
  end
end
