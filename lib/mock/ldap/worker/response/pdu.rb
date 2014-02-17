require 'mock/ldap/worker/response/result_code'
require 'mock/ldap/worker/error'
require 'mock/ldap/worker/tag'

module Mock
  module Ldap
    module Worker
      module Response

        module Pdu
          extend Mock::Ldap::Worker::Tag

          def to_pdu
            result = create_ldap_result(@protocol, @result, @matched_dn, @diagnostic_message)
            create_ldap_message(@message_id, result)
          end

          attr_reader :protocol, :message_id, :result, :matched_dn, :diagnostic_message

          private

          def sanitize_dn(dn)
            unless dn.empty? or dn =~ /^\w+=\w+(,\w+=\w+)*$/
              raise InvalidDNSyntaxError, "#{dn} is not legal as LDAP DN."
            end
            dn
          end

          # See RFC4511 Section 4.1.1
          def create_ldap_message(message_id, protocol_op)
            OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::Integer.new(message_id), protocol_op])
          end

          # See RFC4511 Section 4.1.9
          def create_ldap_result(tag, result, matched_dn, diagnostic_message, referral=nil)
            result = [
              OpenSSL::ASN1::Enumerated.new(RESULT_CODE[result]),
              OpenSSL::ASN1::OctetString.new(matched_dn),
              OpenSSL::ASN1::OctetString.new(diagnostic_message),
            ]
            if referral
              result << OpenSSL::ASN1::OctetString.new(referral, tag=3, tagging=:IMPLICIT, tag_class=:CONTEXT_SPECIFIC)
            end

            OpenSSL::ASN1::Sequence.new(result, tag=Tag::Application[@protocol], tagging=:IMPLICIT, tag_class=:APPLICATION)
          end

        end

      end
    end
  end
end

