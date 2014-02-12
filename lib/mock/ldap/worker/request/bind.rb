require 'openssl'

require 'mock/ldap/worker/request/error'
require 'mock/ldap/worker/tag'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag

        class Bind
          def initialize(message_id, operation)
            @message_id = message_id
            @protocol = :BindRequest
            @operation = operation
            parse_request
          end

          attr_reader :message_id, :protocol, :version, :name, :authentication

          private

          # Parse BindRequest. See RFC4511 Section 4.2
          def parse_request
            unless @operation.value.is_a?(Array)
              raise BerIdenitfierError, "BindRequest is requested to be Constructed ber."
            end

            unless @operation.value.length == 3
              raise BerConstructedLengthError, "length of BindRequest is requested to be exactly 3."
            end

            unless @operation.value[0].is_a?(OpenSSL::ASN1::Integer)
              raise BerIdentifierError, "version of BindRequest is requested to be Universal Integer."
            end
            @version = @operation.value[0].value.to_i
            unless @version == 3
              raise RuntimeError, "We support only ldap version 3."
            end

            unless @operation.value[1].is_a?(OpenSSL::ASN1::OctetString)
              raise BerIdentifierError, "name of BindRequest is requested to be Universal String."
            end
            @name = @operation.value[1].value

            @authentication = parse_authentication_choice(@operation.value[2])
          end

          def parse_authentication_choice(auth)
            unless auth.tag_class == :CONTEXT_SPECIFIC
              raise BerIdentifierError, "authentication of BindRequest is requested to be Context-specific class."
            end

            case auth.tag
            when Tag::Context_Specific[:AuthenticationChoice][:simple]
              if auth.value.is_a?(Array)
                raise BerIdentifierError, "simple AuthenticationChoice of BindRequest is requested to be primitive."
              end
              auth.value
            when Tag::Context_Specific[:AuthenticationChoice][:sasl]
              raise RuntimeError, "We support only simple authentication."
            else
              raise BerIdentifierError, "AuthenticationChoice tag is requested to be 0 or 2."
            end
          end
        end

      end
    end
  end
end
