require 'openssl'

require 'mock/ldap/worker/error'
require 'mock/ldap/worker/tag'
require 'mock/ldap/worker/request/common_parser'
require 'mock/ldap/worker/request/abst_request'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag
        extend Mock::Ldap::Worker::Error

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
end
