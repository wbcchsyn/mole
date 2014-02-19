require 'mole/worker/response'
require 'mole/worker/request'
require 'mole/worker/entry'


module Mole
  module Worker


    def handle(pdu)

      request = Request.parse(pdu)
      response = Response.create(request)

      [request, response]
    end

    def clear
      Entry.clear
    end


    module_function :handle, :clear
  end
end
