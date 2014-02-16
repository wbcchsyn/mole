require 'openssl'

require 'mock/ldap/worker/request/error'
require 'mock/ldap/worker/request/bind'
require 'mock/ldap/worker/request/add'

module Mock
  module Ldap
    module Worker
      module Request

        # See RFC4511 Section 4.1.1
        def parse_ldap_message(pdu)
          unless pdu.is_a?(OpenSSL::ASN1::Sequence)
            raise BerIdentifierError, "LDAPMessage is requested to be Universal SEQUENCE."
          end

          unless pdu.value.length == 2
            raise BerConstructedLengthError, "length of LDAPMessage is requested to be exactly 2."
          end

          unless pdu.value[0].is_a?(OpenSSL::ASN1::Integer)
            raise BerIdentifierError, "message_id of LDAPMessage is requested to be Universal Integer."
          end
          message_id = pdu.value[0].value.to_i

          unless pdu.value[1].tag_class == :APPLICATION
            raise BerIdentifierError, "protocolOp of LDAPMessage is requested to be Application class ber."
          end
          protocol = pdu.value[1].tag
          operation = pdu.value[1]


          [message_id, protocol, operation]
        end

        module_function :parse_ldap_message

      end
    end
  end
end
