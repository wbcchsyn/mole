require 'mock/ldap/worker/response/abst_response'
require 'mock/ldap/worker/response/Entry'

module Mock
  module Ldap
    module Worker
      module Response
        extend Mock::Ldap::Worker::Error

        class Modify < AbstResponse

          def initialize(request)
            @protocol = :ModifyResponse
            @matched_dn = request.object
            @diagnostic_message = "Modify #{@matched_dn} entry."
            super
          end

          private

          def execute
            Entry.modify(@request.object, @request.changes)
          end

        end

      end
    end
  end
end
