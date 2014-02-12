require 'mock/ldap/worker/response'
require 'mock/ldap/worker/request'
require 'mock/ldap/worker/tag'


module Mock
  module Ldap
    module Worker

      def handle(pdu)
        message_id, protocol, request_body = Request.parse_ldap_message(pdu)

        case protocol
        when Tag::Application[:BindRequest]
          request = Request::Bind.new(message_id, request_body)
          response = Response::Bind.new(request)
          [request, response]
        else
          raise RuntimeError, "Receive unknown request tag."
        end
      end

      module_function :handle

    end
  end
end
