require 'mole/worker/response/abst_response'

module Mole
  module Worker
    module Response


      class ModifyDn < AbstResponse

        def initialize(request)
          @protocol = :ModifyDNResponse
          @matched_dn = @request.entry
          super
          # Create message
          if @result == :success
            operation = @request.deleteolddn ? "Rename" : "Copy"
            to = @request.newrdn
            to = to + ',' + @request.newrdn unless @request.newrdn.empty?
            @diagnostic_message = "#{operation} #{@request.entry} to #{to}."
          end
        end

        private

        def execute
          Entry.modify_dn(@request.entry,
                          @request.newrdn,
                          @request.deleteolddn,
                          @request.new_superior)
        end

      end


    end
  end
end

