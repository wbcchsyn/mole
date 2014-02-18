require 'openssl'

require 'mock/ldap/worker/error'
require 'mock/ldap/worker/tag'
require 'mock/ldap/worker/request/abst_request'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag
        extend Mock::Ldap::Worker::Error

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
end
