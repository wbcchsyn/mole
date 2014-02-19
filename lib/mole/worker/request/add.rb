require 'mole/worker/request/common_parser'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Add
        include AbstRequest

        def initialize(*args)
          @protocol = :AddRequest
          super
        end

        attr_reader :entry, :attributes

        private

        # Parse AddRequest. See RFC4511 Section 4.7
        def parse_request
          CommonParser.sanitize_length(@operation, 2, 'AddRequest')
          @entry = CommonParser.parse_octet_string(@operation.value[0], 'entry of AddRequest')
          @attributes = CommonParser.parse_sequence(@operation.value[1], 'attributes of AddRequest').map do |attribute|
            CommonParser.parse_attribute(attribute)
          end
        end


      end

      private_constant :Add


    end
  end
end
