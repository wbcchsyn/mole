module Mock
  module Ldap
    module Worker
      module Request

        class Error < RuntimeError
        end

        class BerIdentifierError < Error
        end

        class BerConstructedLengthError < Error
        end

      end
    end
  end
end
