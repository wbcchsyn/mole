require 'mock/ldap/worker/response/result_code'

module Mock
  module Ldap
    module Worker
      module Response


        class Error < StandardError
        end

        class UnwillingToPerformError < Error
          @@code = :unwillingToPerform
          def code
            @@code
          end
        end

        class EntryAlreadyExistsError < Error
          @@code = :entryAlreadyExists
          def code
            @@code
          end
        end

        class InvalidDNSyntaxError < Error
          @@code = :invalidDNSyntax
          def code
            @@code
          end
        end

      end
    end
  end
end
