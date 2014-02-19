require 'mole/worker/response/abst_response'
require 'mole/worker/entry'

module Mole
  module Worker
    module Response


      class Del
        include AbstResponse

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

      private_constant :Del


    end
  end
end

