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
        when Tag::Application[:AddRequest]
          request = Request::Add.new(message_id, request_body)
          response = Response::Add.new(request)
          [request, response]
        when Tag::Application[:SearchRequest]
          request = Request::Search.new(message_id, request_body)
          response = Response::Search.new(request)
          [request, response]
        when Tag::Application[:ModifyRequest]
          request = Request::Modify.new(message_id, request_body)
          response = Response::Modify.new(request)
          [request, response]
        else
          raise RuntimeError, "Receive unknown request tag."
        end
      end

      def clear
        Response::Entry.clear
      end

      module_function :handle, :clear

    end
  end
end
