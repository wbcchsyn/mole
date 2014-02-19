require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error


      class Unbind < AbstRequest

        def initialize(*args)
          @protocol = :UnbindRequest
          super
        end

      end


    end
  end
end
