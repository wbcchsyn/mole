require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Unbind
        include AbstRequest

        def initialize(*args)
          @protocol = :UnbindRequest
          super
        end

      end

      private_constant :Unbind


    end
  end
end
