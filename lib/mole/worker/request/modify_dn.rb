require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/abst_request'
require 'mole/worker/request/common_parser'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error


      class ModifyDn < AbstRequest
        def initialize(*args)
          @protocol = :ModifyDNRequest
          super
        end

        attr_reader :entry, :newrdn, :deleteoldrdn, :new_superior

        private

        def parse_request
          Request.sanitize_length(@operation, 4, 'ModifyDNRequest')

          @entry = Request.parse_ldap_dn(@operation.value[0], 'entry of ModifyDNRequest')
          @newrdn = Request.parse_ldap_dn(@operation.value[1], 'newrdn of ModifyDNRequest')
          @deleteoldrdn = Request.parse_boolean(@operation.value[2], 'deleteoldrdn of ModifyDNRequest')
          @new_superior = Request.parse_ldap_dn(@operation.value[3], 'entry of ModifyDNRequest')
          if @newrdn.empty?
            raise Error::ProtocolError, "newrdn of ModifyDNRequest must not empty."
          end
        end

      end


    end
  end
end
