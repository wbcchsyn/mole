require 'mock/ldap/worker/response/abst_response'
require 'mock/ldap/worker/response/Entry'

module Mock
  module Ldap
    module Worker
      module Response

        class Add < AbstResponse

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
      end
    end
  end
end
