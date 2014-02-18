require 'openssl'

require 'mock/ldap/worker/error'
require 'mock/ldap/worker/request/bind'
require 'mock/ldap/worker/request/unbind'
require 'mock/ldap/worker/request/search'
require 'mock/ldap/worker/request/modify.rb'
require 'mock/ldap/worker/request/add'
require 'mock/ldap/worker/request/del'
require 'mock/ldap/worker/request/modify_dn'
require 'mock/ldap/worker/request/compare'
require 'mock/ldap/worker/request/abandon'
require 'mock/ldap/worker/request/extend'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag
        extend Mock::Ldap::Worker::Error

        # See RFC4511 Section 4.1.1
        def parse_ldap_message(pdu)
          unless pdu.is_a?(OpenSSL::ASN1::Sequence)
            raise Error::ProtocolError, "LDAPMessage is requested to be Universal SEQUENCE."
          end

          unless pdu.value.length == 2
            raise Error::ProtocolError, "length of LDAPMessage is requested to be exactly 2."
          end

          unless pdu.value[0].is_a?(OpenSSL::ASN1::Integer)
            raise Error::ProtocolError, "message_id of LDAPMessage is requested to be Universal Integer."
          end
          message_id = pdu.value[0].value.to_i

          unless pdu.value[1].tag_class == :APPLICATION
            raise Error::ProtocolError, "protocolOp of LDAPMessage is requested to be Application class ber."
          end
          operation = pdu.value[1]

          [message_id, operation]
        end

        module_function :parse_ldap_message

      end
    end
  end
end
