require 'openssl'

require 'mole/worker/error'
require 'mole/worker/request/bind'
require 'mole/worker/request/unbind'
require 'mole/worker/request/search'
require 'mole/worker/request/modify.rb'
require 'mole/worker/request/add'
require 'mole/worker/request/del'
require 'mole/worker/request/modify_dn'
require 'mole/worker/request/compare'
require 'mole/worker/request/abandon'
require 'mole/worker/request/extend'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error

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
