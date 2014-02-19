require 'mole/worker/response/abst_response'
require 'mole/worker/entry'

module Mole
  module Worker
    module Response

      class Add
        include AbstResponse

        def initialize(request)
          @protocol = :AddResponse
          @matched_dn = request.entry
          @diagnostic_message = "Succeeded to add #{request.entry}."
          super
        end

        private

        def execute
          Entry.add(@request.entry, @request.attributes)
        end

      end

      private_constant :Add


    end
  end
end
