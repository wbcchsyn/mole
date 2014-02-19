require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Compare
        include AbstRequest

        def initialize(*args)
          @protocol = :CompareRequest
          super
        end

      end

      private_constant :Compare


    end
  end
end
