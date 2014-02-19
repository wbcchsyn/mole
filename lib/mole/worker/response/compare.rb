require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class Compare
        include AbstResponse

        def initialize(request)
          @protocol = :CompareRdnResponse
          @matched_dn = ''
          @diagnostic_message = "CompareRdnResponse is not implemented yet."
          super
          @result = :protocolError
        end

      end

      private_constant :Compare


    end
  end
end

