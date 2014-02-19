require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class Bind < AbstResponse

        def initialize(request)
          @protocol = :BindResponse
          @matched_dn = request.name
          @diagnostic_message = "Bind Succeeded by #{request.name}."
          super
        end

        private

      end


    end
  end
end

