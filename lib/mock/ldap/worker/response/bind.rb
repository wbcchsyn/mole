require 'mock/ldap/worker/response/pdu'

module Mock
  module Ldap
    module Worker
      module Response

        class Bind
          include Pdu

          def initialize(request)
            @protocol = :BindResponse
            @message_id = request.message_id
            @result = :success
            @matched_dn = request.name
            @diagnostic_message = "Bind Succeeded by #{request.name}."
          end

        end
      end
    end
  end
end

