require 'openssl'

require 'mock/ldap/worker/error'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Error

        class AbstRequest
          def initialize(message_id, operation)
            @message_id = message_id
            @operation = operation
            parse_request
          rescue Error::LdapError
            @error = $!
          end

          attr_reader :message_id, :protocol, :error

          private

          # Implement in each child class
          def parse_request
            raise RuntimeError, "Abstruct method parse_request is called."
          end
        end

      end
    end
  end
end
