require 'mole/worker/error'
require 'mole/worker/request/abst_request'
require 'mole/worker/request/common_parser'

module Mole
  module Worker
    module Request


      class ModifyDn
        extend Mole::Worker::Error

        include AbstRequest

        def initialize(*args)
          @protocol = :ModifyDNRequest
          super
        end

        attr_reader :entry, :newrdn, :deleteoldrdn, :new_superior

        private

        def parse_request
          CommonParser.sanitize_constructed(@operation, 'ModifyDNRequest')

          # The operation length depends on whether optional parameter, 'newSuperior' is or not.
          unless @operation.value.length == 3 or @operation.value.length == 4
            message = "The length of ModifyDNRequest is requested to be 3 or 4."
            raise Error::ProtocolError, message
          end

          @entry = CommonParser.parse_ldap_dn(@operation.value[0], 'entry of ModifyDNRequest')
          if @entry.empty?
            raise Error::ProtocolError, "entry of ModifyDNRequest must not empty."
          end

          @newrdn = CommonParser.parse_ldap_dn(@operation.value[1], 'newrdn of ModifyDNRequest')
          if @newrdn.empty?
            raise Error::ProtocolError, "newrdn of ModifyDNRequest must not empty."
          end

          @deleteoldrdn = CommonParser.parse_boolean(@operation.value[2], 'deleteoldrdn of ModifyDNRequest')

          if @operation.value[3]
            CommonParser.sanitize_class(@operation.value[3], :CONTEXT_SPECIFIC, 'newSuperior of ModifyDNRequest')
            CommonParser.sanitize_primitive(@operation.value[3], 'newSuperior of ModifyDNRequest')
            @new_superior = @operation.value[3].value
          else
            @new_superior = nil
          end
        end

      end

      private_constant :ModifyDn


    end
  end
end
