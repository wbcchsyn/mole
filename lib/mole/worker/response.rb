require 'mole/worker/response/bind'
require 'mole/worker/response/search'
require 'mole/worker/response/modify'
require 'mole/worker/response/add'
require 'mole/worker/response/del'
require 'mole/worker/response/modify_dn'
require 'mole/worker/response/compare'
require 'mole/worker/response/extend'


module Mole
  module Worker
    module Response


      def create(request)
        case request.protocol
        when :BindRequest
          Bind.new(request)
        when :UnbindRequest
          nil
        when :SearchRequest
          Search.new(request)
        when :ModifyRequest
          Modify.new(request)
        when :AddRequest
          Add.new(request)
        when :DelRequest
          Del.new(request)
        when :ModifyDNRequest
          ModifyDn.new(request)
        when :CompareRequest
          Compaire.new(request)
        when :AbandonRequest
          nil
        when :ExtendRequest
          Extend.new(request)
        else
          raise Error::ProtocolError, "Receive unknown request tag."
        end
      end

      module_function :create
    end

    private_constant :Response
  end
end
