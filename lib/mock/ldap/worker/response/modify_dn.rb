require 'mock/ldap/worker/response/abst_response'

module Mock
  module Ldap
    module Worker
      module Response

        class ModifyDn < AbstResponse

          def initialize(request)
            @protocol = :ModifyDNResponse
            @matched_dn = ''
            @diagnostic_message = "ModifyRdnResponse is not implemented yet."
            super
            @result = :protocolError
          end

          private

        end
      end
    end
  end
end

