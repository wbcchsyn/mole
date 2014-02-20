require 'mole/worker/response/abst_response'
require 'mole/worker/entry'

module Mole
  module Worker
    module Response


      class ModifyDn
        include AbstResponse

        def initialize(request)
          @protocol = :ModifyDNResponse
          @matched_dn = request.entry
          @diagnostic_message = 'hoge'
          super
          # Create message
          if @result == :success
            operation = @request.deleteoldrdn ? "Rename" : "Copy"
            to = @request.newrdn
            to = to + ',' + @request.newrdn unless @request.newrdn.empty?
            @diagnostic_message = "#{operation} #{@request.entry} to #{to}."
          end
        end

        private

        def execute
          Entry.modify_dn(@request.entry,
                          @request.newrdn,
                          @request.deleteoldrdn,
                          @request.new_superior)
        end

      end

      private_constant :ModifyDn


    end
  end
end

