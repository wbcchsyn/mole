require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request


      class Extend
        include AbstRequest

        def initialize(*args)
          @protocol = :ExtendRequest
          super
        end

      end

      private_constant :Extend


    end
  end
end
