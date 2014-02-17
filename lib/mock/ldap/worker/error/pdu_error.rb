module Mock
  module Ldap
    module Worker
      module Error

        class PduError < RuntimeError
        end

        class PduIdentifierError < PduError
        end

        class PduConstructedLengthError < PduError
        end

      end
    end
  end
end
