require 'mock/ldap/worker/response/abst_response'

module Mock
  module Ldap
    module Worker
      module Response

        class Del < AbstResponse

          def initialize(request)
            @protocol = :DelResponse
            @matched_dn = ''
            @diagnostic_message = "DelResponse is not implemented yet."
            super
            @result = :protocolError
          end

          private

        end
      end
    end
  end
end

