require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error


      class Compare < AbstRequest

        def initialize(*args)
          @protocol = :CompareRequest
          super
        end

      end


    end
  end
end
