require 'mole/worker/response'
require 'mole/worker/request'
require 'mole/worker/tag'
require 'mole/worker/entry'


module Mole
  module Worker


    def handle(pdu)
      message_id, operation = Request.parse_ldap_message(pdu)

      case Tag::Application[operation.tag]
      when :BindRequest
        request = Request::Bind.new(message_id, operation)
        response = Response::Bind.new(request)
      when :UnbindRequest
        request = Request::Unbind.new(message_id, operation)
        response = nil
      when :SearchRequest
        request = Request::Search.new(message_id, operation)
        response = Response::Search.new(request)
      when :ModifyRequest
        request = Request::Modify.new(message_id, operation)
        response = Response::Modify.new(request)
      when :AddRequest
        request = Request::Add.new(message_id, operation)
        response = Response::Add.new(request)
      when :DelRequest
        request = Request::Del.new(message_id, operation)
        response = Response::Del.new(request)
      when :ModifyDNRequest
        request = Request::ModifyDN.new(message_id, operation)
        response = Response::ModifyDN.new(request)
      when :CompareRequest
        request = Request::CompaireRequest.new(message_id, operation)
        response = Response::CompaireRequest.new(request)
      when :AbandonRequest
        request = Request::AbandonRequest.new(message_id, operation)
        response = nil
      when :ExtendRequest
        request = Request::ExtendRequestRequest.new(message_id, operation)
        response = Response::ExtendRequestRequest.new(request)
      else
        raise Error::ProtocolError, "Receive unknown request tag."
      end

      [request, response]
    end

    def clear
      Entry.clear
    end

    module_function :handle, :clear


  end
end
