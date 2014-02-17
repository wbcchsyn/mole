require 'mock/ldap/worker/response/pdu'
require 'mock/ldap/worker/error'
require 'mock/ldap/worker/response/Entry'

module Mock
  module Ldap
    module Worker
      module Response
        extend Mock::Ldap::Worker::Error

        class Modify
          include Pdu

          def initialize(request)
            @protocol = :ModifyResponse
            @message_id = request.message_id
            @matched_dn = sanitize_dn(request.object)
            Entry.modify(request.object, request.changes)
            @result = :success
            @diagnostic_message = "Modify #{@matched_dn} entry."
          rescue Error::LdapError
            @result = $!.code
            @diagnostic_message = $!.message
          end
        end

      end
    end
  end
end
