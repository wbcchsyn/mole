require 'mock/ldap/response'
require 'mock/ldap/request'
require 'mock/ldap/tag'


module Mock
  module Ldap


    def handle(pdu)
      message_id, protocol, request_body = Mock::Ldap::Request.parse_ldap_message(pdu)

      case protocol
      when Tag::Application[:BindRequest]
        request = Request::Bind.new(message_id, :BindRequest, request_body)
        response = Ldap::Response::Bind.new(request)
        response.to_ber
      end
    end

    module_function :handle
  end
end
