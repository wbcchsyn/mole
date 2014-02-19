require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class Del < AbstResponse

        def initialize(request)
          @protocol = :DelResponse
          @matched_dn = request.dn
          @diagnostic_message = "Delete #{request.dn}"
          super
        end

        private

        def execute
          Entry.del(@request.dn)
        end

      end


    end
  end
end

