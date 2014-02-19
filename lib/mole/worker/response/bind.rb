require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class Bind
        include AbstResponse

        def initialize(request)
          @protocol = :BindResponse
          @matched_dn = request.name
          @diagnostic_message = "Bind Succeeded by #{request.name}."
          super
        end

        private

      end

      private_constant :Bind


    end
  end
end

