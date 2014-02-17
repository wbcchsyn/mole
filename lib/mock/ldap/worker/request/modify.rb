require 'openssl'

require 'mock/ldap/worker/request/error'
require 'mock/ldap/worker/tag'
require 'mock/ldap/worker/request/common_parser'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag

        class Modify
          def initialize(message_id, operation)
            @message_id = message_id
            @protocol = :ModifyRequest
            @operation = operation
            parse_request
          end

          attr_reader :message_id, :protocol, :object, :changes

          private

          # Parse ModifyRequest. See RFC4511 Section 4.6
          def parse_request
            unless @operation.value.is_a?(Array)
              raise BerIdentifierError, "ModifyRequest is requested to be Constructed ber."
            end

            unless @operation.value.length == 2
              raise BerConstructedLengthError, "length of ModifyRequest is requested to be exactly 2."
            end

            unless @operation.value[0].is_a?(OpenSSL::ASN1::OctetString)
              raise BerIdentifierError, "object of ModifyRequest is requested to be Universal OctetString."
            end
            @object = @operation.value[0].value

            unless @operation.value[1].is_a?(OpenSSL::ASN1::Sequence)
              raise BerIdentierError, "changes of ModifyRequest is requested to be Universal Sequence."
            end

            @changes = @operation.value[1].value.map do |pdu|
              parse_operation(pdu)
            end
          end

          def parse_operation(pdu)
            unless pdu.is_a?(OpenSSL::ASN1::Sequence)
              raise BerIdentifierError, "Each change of ModifyRequest changes is requested to be Universal Sequence."
            end

            unless pdu.value[0].is_a?(OpenSSL::ASN1::Enumerated)
              raise BerIdentifierError, "Each oparation of ModifyRequest changes is requested to be Universal Enumerated."
            end
            case pdu.value[0].value
            when Tag::ChangesOperation[:add]
              operation = :add
            when Tag::ChangesOperation[:delete]
              operation = :delete
            when Tag::ChangesOperation[:replace]
              operation = :replace
            else
              raise RuntimeError, 'Receive unknown operation.'
            end

            modification = Request::parse_partial_attribute(pdu.value[1])

            [operation, modification]
          end
        end

      end
    end
  end
end
