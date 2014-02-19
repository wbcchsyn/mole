require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/common_parser'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Modify
        extend Mole::Worker::Tag
        extend Mole::Worker::Error

        include AbstRequest

        def initialize(*args)
          @protocol = :ModifyRequest
          super
        end

        attr_reader :object, :changes

        private

        # Parse ModifyRequest. See RFC4511 Section 4.6
        def parse_request
          CommonParser.sanitize_length(@operation, 2, 'ModifyRequest')

          @object = CommonParser.parse_ldap_dn(@operation.value[0], 'object of ModifyRequest')
          @changes = CommonParser.parse_sequence(@operation.value[1], 'changes of ModifyRequest').map do |pdu|
            parse_operation(pdu)
          end
        end

        def parse_operation(pdu)
          CommonParser.parse_sequence(pdu, 'Each of ModifyRequest changes')
          operation = Tag::ChangeOperation[CommonParser.parse_enumerated(pdu.value[0], 'operation of ModifyRequest changes')]
          modification = CommonParser.parse_partial_attribute(pdu.value[1])
          [operation, modification]

        rescue Error::KeyError
          raise Error::ProtocolError, 'Receive unknown operation.'
        end

      end

      private_constant :Modify


    end
  end
end
