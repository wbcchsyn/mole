require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error


      class Del < AbstRequest
        def initialize(*args)
          @protocol = :DelRequest
          super
        end

        attr_reader :dn

        private

        # Parse DelRequest. See RFC4511 Section 4.8
        def parse_request
          Request.sanitize_primitive(@operation, 'DelRequest')
          @dn = @operation.value
        end

      end


    end
  end
end
