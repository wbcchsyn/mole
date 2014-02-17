require 'mock/ldap/worker/response/abst_response'

module Mock
  module Ldap
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

          def execute
            # Do nothing.
          end

        end
      end
    end
  end
end

