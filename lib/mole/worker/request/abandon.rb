require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Abandon
        include AbstRequest

        def initialize(*args)
          @protocol = :AbandonRequest
          super
        end
      end

      private_constant :Abandon


    end
  end
end
