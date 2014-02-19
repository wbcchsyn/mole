require 'mole/worker/response/abst_response'
require 'mole/worker/entry'

module Mole
  module Worker
    module Response
      extend Mole::Worker::Error

      class Modify
        include AbstResponse

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

      private_constant :Modify


    end
  end
end
