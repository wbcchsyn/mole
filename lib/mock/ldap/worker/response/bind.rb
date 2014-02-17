require 'mock/ldap/worker/response/pdu'
require 'mock/ldap/worker/error'

module Mock
  module Ldap
    module Worker
      module Response
        extend Mock::Ldap::Worker::Error

        class Bind
          include Pdu

          def initialize(request)
            @protocol = :BindResponse
            @message_id = request.message_id
            @result = :success
            @matched_dn = sanitize_dn(request.name)
            @diagnostic_message = "Bind Succeeded by #{request.name}."
          rescue Error::LdapError
            @result = $!.code
            @diagnostic_message = $!.message
          end

        end
      end
    end
  end
end

