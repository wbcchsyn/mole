require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class Extend
        include AbstResponse

        def initialize(request)
          @protocol = :ExtendResponse
          @matched_dn = ''
          @diagnostic_message = "ExtendResponse is not implemented yet."
          super
          @result = :protocolError
        end

      end

      private_constant :Extend


    end
  end
end

