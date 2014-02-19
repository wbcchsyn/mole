require 'mole/worker/error'
require 'mole/worker/request/common_parser'

module Mole
  module Worker
    module Request


      module AbstRequest
        def initialize(message_id, operation)
          @message_id = message_id
          @operation = operation

          parse_request

        rescue Mole::Worker::Error::LdapError
          @error = $!
        end

        attr_reader :message_id, :protocol, :error

        private

        def parse_request
          # Implement in each child class
        end
      end

      private_constant :AbstRequest

    end
  end
end
