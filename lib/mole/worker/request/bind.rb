require 'openssl'

require 'mole/worker/error'
require 'mole/worker/tag'
require 'mole/worker/request/abst_request'

module Mole
  module Worker
    module Request
      extend Mole::Worker::Tag
      extend Mole::Worker::Error


      class Bind < AbstRequest
        def initialize(message_id, operation)
          @protocol = :BindRequest
          super
        end

        attr_reader :version, :name, :authentication

        private

        # Parse BindRequest. See RFC4511 Section 4.2
        def parse_request
          Request.sanitize_length(@operation, 3, 'BindRequest')

          @version = Request.parse_integer(@operation.value[0], 'version of BindRequest')
          @name = Request.parse_octet_string(@operation.value[1], 'name of BindRequest')
          @authentication = parse_authentication_choice(@operation.value[2])

          unless @version == 3
            raise Error::ProtocolError, "We support only ldap version 3."
          end
        end

        def parse_authentication_choice(auth)
          Request.sanitize_class(auth, :CONTEXT_SPECIFIC, 'authentication of BindRequest')

          case auth.tag
          when Tag::AuthenticationChoice[:simple]
            Request.sanitize_primitive(auth, 'simple AuthenticationChoice of BindRequest')
            auth.value
          when Tag::Context_Specific[:AuthenticationChoice][:sasl]
            raise Error::AuthMethodNotSupported, "We support only simple authentication."
          else
            raise Error::ProtocolError, "AuthenticationChoice tag is requested to be 0 or 2."
          end
        end

      end


    end
  end
end
