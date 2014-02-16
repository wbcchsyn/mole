require 'mock/ldap/worker/response/error'

module Mock
  module Ldap
    module Worker
      module Response


        class Entry

          class Attributes < Hash
          end

          @@base = nil
          @@mutex = Mutex.new

          def initialize(dn, attributes)
            @dn = dn
            @attributes = Attributes[attributes]
            @children = {}
          end

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
        end


      end
    end
  end
end
