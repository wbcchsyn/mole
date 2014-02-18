require 'mock/ldap/worker/response/result_code'
require 'mock/ldap/worker/error'
require 'mock/ldap/worker/tag'

module Mock
  module Ldap
    module Worker
      module Response
        extend Mock::Ldap::Worker::Tag
        extend Mock::Ldap::Worker::Error

        class AbstResponse

          def initialize(request)
            @message_id = request.message_id
            @result = :success
            @request = request

            raise request.error if request.error
            sanitize_dn
            execute
          rescue Error::LdapError
            @matched_dn = '' unless @matched_dn
            @result = ($!.code || :operationsError)
            @diagnostic_messge = ($!.message || '')
          end

          def to_pdu
            result = create_ldap_result
            [create_ldap_message(result)]
          end

          attr_reader :result, :diagnostic_message

          private

          def execute
            # Implement in each child class.
          end

          def sanitize_dn
            unless @matched_dn.empty? or @matched_dn =~ /^\w+=\w+(,\w+=\w+)*$/
              raise Error::InvalidDNSyntaxError, "#{@matched_dn} is ill formed as LDAP DN."
            end
          end

          # See RFC4511 Section 4.1.1
          def create_ldap_message(protocol_op)
            OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::Integer.new(@message_id), protocol_op])
          end

          # See RFC4511 Section 4.1.9
          def create_ldap_result
            result = [
              OpenSSL::ASN1::Enumerated.new(RESULT_CODE[@result]),
              OpenSSL::ASN1::OctetString.new(@matched_dn),
              OpenSSL::ASN1::OctetString.new(@diagnostic_message),
            ]

            OpenSSL::ASN1::Sequence.new(result, tag=Tag::Application[@protocol], tagging=:IMPLICIT, tag_class=:APPLICATION)
          end

        end

      end
    end
  end
end
