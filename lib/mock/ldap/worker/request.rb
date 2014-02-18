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
          sanitize_length(pdu, 2, 'LDAPMessage')

          contents = parse_sequence(pdu, 'LDAPMessage')

          message_id = parse_integer(contents[0], 'message_id of LDAPMessage')

          sanitize_class(contents[1], :APPLICATION, 'protocolOp of LDAPMessage')
          operation = contents[1]

          [message_id, operation]
        end

        module_function :parse_ldap_message
      end
    end
  end
end
