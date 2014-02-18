require 'mock/ldap/worker/response/abst_response'

module Mock
  module Ldap
    module Worker
      module Response

        class Extend < AbstResponse

          def initialize(request)
            @protocol = :ExtendResponse
            @matched_dn = ''
            @diagnostic_message = "ExtendResponse is not implemented yet."
            super
            @result = :protocolError
          end

          private

        end
      end
    end
  end
end

