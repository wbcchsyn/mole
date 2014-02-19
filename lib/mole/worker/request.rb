require 'mole/worker/request/common_parser'
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
require 'mole/worker/tag'


module Mole
  module Worker
    module Request


      def parse(pdu)
        CommonParser.sanitize_length(pdu, 2, 'LDAPMessage')
        contents = CommonParser.parse_sequence(pdu, 'LDAPMessage')

        message_id = CommonParser.parse_integer(contents[0], 'message_id of LDAPMessage')

        CommonParser.sanitize_class(contents[1], :APPLICATION, 'protocolOp of LDAPMessage')
        operation = contents[1]

        case Tag::Application[operation.tag]
        when :BindRequest
          Bind.new(message_id, operation)
        when :UnbindRequest
          Unbind.new(message_id, operation)
        when :SearchRequest
          Search.new(message_id, operation)
        when :ModifyRequest
          Modify.new(message_id, operation)
        when :AddRequest
          Add.new(message_id, operation)
        when :DelRequest
          Del.new(message_id, operation)
        when :ModifyDNRequest
          ModifyDN.new(message_id, operation)
        when :CompareRequest
          CompaireRequest.new(message_id, operation)
        when :AbandonRequest
          AbandonRequest.new(message_id, operation)
        when :ExtendRequest
          ExtendRequestRequest.new(message_id, operation)
        else
          raise Error::ProtocolError, "Receive unknown request tag."
        end

      end

      module_function :parse


    end

    private_constant :Request
  end
end
