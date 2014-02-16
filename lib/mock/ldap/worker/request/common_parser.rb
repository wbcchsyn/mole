require 'openssl'

require 'mock/ldap/worker/request/error'

module Mock
  module Ldap
    module Worker
      module Request

        # See RFC4511 Section 4.1.7
        def parse_attribute(pdu)
          type, vals = parse_partial_attribute(pdu)

          if vals.empty?
            raise BerConstructedLengthError, "vals of Attribute should not be empty."
          end

          [type, vals]
        end

        # See RFC4511 Section 4.1.7
        def parse_partial_attribute(pdu)
          unless pdu.is_a?(OpenSSL::ASN1::Sequence)
            raise BerIdentifierError, "Attribute and PartialAttribute is requested to be Universal Sequence."
          end

          unless pdu.value.length == 2
            raise BerConstructedLengthError, "The length of Attribute or PartialAttribute is requested to be exactrly 2."
          end

          unless pdu.value[0].is_a?(OpenSSL::ASN1::OctetString)
            raise BerIdentifierError, "type of Attribute or PartialAttribute is requested to be Universal OctetString."
          end
          type = pdu.value[0].value

          unless pdu.value[1].is_a?(OpenSSL::ASN1::Set)
            raise BerIdentifierError, "vals of Attribute or PartialAttribute is requested to be Universal Set."
          end
          vals = pdu.value[1].value.map do |val|
            # Some ldap tools may send UniversalInteger and so on.
            # However, it should be OctetString according to RFC
            unless val.is_a?(OpenSSL::ASN1::OctetString)
              raise BerIdentifierError, "Each value of Attribute or PartialAttribute vals is requested to be Universal OctetString."
            end
            val.value
          end

          [type, vals]
        end

        module_function :parse_attribute, :parse_partial_attribute
      end
    end
  end
end
