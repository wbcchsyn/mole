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
            unless @operation.value.is_a?(Array)
              raise Error::ProtocolError, "AddRequest is requested to be Constructed ber."
            end

            unless @operation.value.length == 2
              raise Error::ProtocolError, "length of AddRequest is requested to be exactly 2."
            end

            unless @operation.value[0].is_a?(OpenSSL::ASN1::OctetString)
              raise Error::ProtocolError, "entry of AddRequest is requested to be Universal OctetString."
            end
            @entry = @operation.value[0].value

            # TODO Parse attributes
            @attributes = @operation.value[1].value.map do |attribute|
              Request::parse_attribute(attribute)
            end
          end

        end

      end
    end
  end
end
