require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/common_parser'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error

      class Add < AbstRequest
        def initialize(message_id, operation)
          @protocol = :AddRequest
          super
        end

        attr_reader :entry, :attributes

        private

        # Parse AddRequest. See RFC4511 Section 4.7
        def parse_request
          Request.sanitize_length(@operation, 2, 'AddRequest')
          @entry = Request.parse_octet_string(@operation.value[0], 'entry of AddRequest')
          @attributes = Request.parse_sequence(@operation.value[1], 'attributes of AddRequest').map do |attribute|
            Request::parse_attribute(attribute)
          end
        end


      end
    end
  end
end
