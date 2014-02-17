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

        class Modify < AbstRequest
          def initialize(message_id, operation)
            @protocol = :ModifyRequest
            super
          end

          attr_reader :object, :changes

          private

          # Parse ModifyRequest. See RFC4511 Section 4.6
          def parse_request
            unless @operation.value.is_a?(Array)
              raise Error::PduIdentifierError, "ModifyRequest is requested to be Constructed ber."
            end

            unless @operation.value.length == 2
              raise Error::PduConstructedLengthError, "length of ModifyRequest is requested to be exactly 2."
            end

            unless @operation.value[0].is_a?(OpenSSL::ASN1::OctetString)
              raise Error::PduIdentifierError, "object of ModifyRequest is requested to be Universal OctetString."
            end
            @object = @operation.value[0].value

            unless @operation.value[1].is_a?(OpenSSL::ASN1::Sequence)
              raise Error::PduIdentierError, "changes of ModifyRequest is requested to be Universal Sequence."
            end

            @changes = @operation.value[1].value.map do |pdu|
              parse_operation(pdu)
            end
          end

          def parse_operation(pdu)
            unless pdu.is_a?(OpenSSL::ASN1::Sequence)
              raise Error::PduIdentifierError, "Each change of ModifyRequest changes is requested to be Universal Sequence."
            end

            unless pdu.value[0].is_a?(OpenSSL::ASN1::Enumerated)
              raise Error::PduIdentifierError, "Each oparation of ModifyRequest changes is requested to be Universal Enumerated."
            end

            operation = Tag::ChangeOperation[pdu.value[0].value.to_i]
            modification = Request::parse_partial_attribute(pdu.value[1])
            [operation, modification]

          rescue Error::KeyError
            raise RuntimeError, 'Receive unknown operation.'
          end

        end

      end
    end
  end
end
