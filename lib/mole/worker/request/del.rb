require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Del
        include AbstRequest

        def initialize(*args)
          @protocol = :DelRequest
          super
        end

        attr_reader :dn

        private

        # Parse DelRequest. See RFC4511 Section 4.8
        def parse_request
          CommonParser.sanitize_primitive(@operation, 'DelRequest')
          @dn = @operation.value
        end

      end

      private_constant :Del


    end
  end
end
