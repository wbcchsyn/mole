require 'mock/ldap/worker/response/pdu'
require 'mock/ldap/worker/response/error'
require 'mock/ldap/worker/response/Entry'

module Mock
  module Ldap
    module Worker
      module Response

        class Add
          include Pdu

          def initialize(request)
            @protocol = :AddResponse
            @message_id = request.message_id
            @matched_dn = request.entry
            Entry.add(request.entry, request.attributes)
            @result = :success
            @diagnostic_message = "Succeeded to add #{request.entry}."
          rescue Error
            @result = $!.code
            @diagnostic_message = $!.message
          end

        end
      end
    end
  end
end

