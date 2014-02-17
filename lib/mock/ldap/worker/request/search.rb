require 'openssl'

require 'mock/ldap/worker/error'
require 'mock/ldap/worker/tag'
require 'mock/ldap/worker/request/common_parser'

module Mock
  module Ldap
    module Worker
      module Request
        extend Mock::Ldap::Worker::Tag
        extend Mock::Ldap::Worker::Error

        class Search
          def initialize(message_id, operation)
            @message_id = message_id
            @protocol = :SearchRequest
            @operation = operation
            parse_request
          end

          attr_reader :message_id, :protocol, :base_object, :scope, :deref_aliases, :size_limit, :time_limit, :types_only, :filter, :attributes

          # Parse SearchRequest. See RFC4511 Section 4.5
          def parse_request
            unless @operation.value.is_a?(Array)
              raise Error::PduIdenitfierError, "SearchRequest is requested to be Constructed ber."
            end

            unless @operation.value.length == 8
              raise Error::PduConstructedLengthError, "length of SearchRequest is requested to be exactly 8."
            end

            unless @operation.value[0].is_a?(OpenSSL::ASN1::OctetString)
              raise Error::PduIdentifierError, "baseObject of SearchRequest is requested to be Universal OctetString."
            end
            @base_object = @operation.value[0].value

            unless @operation.value[1].is_a?(OpenSSL::ASN1::Enumerated)
              raise Error::PduIdentifierError, "scope of SearchRequest is requested to be Universal Enumerated."
            end
            case @operation.value[1].value.to_i
            when Tag::Scope[:base_object]
              @scope = :base_object
            when Tag::Scope[:single_level]
              @scope = :single_level
            when Tag::Scope[:whole_subtree]
              @scope = :whole_subtree
            else
              raise RuntimeError, "scope of SearchRequest is requested to be 0 or 1 or 2."
            end

            unless @operation.value[2].is_a?(OpenSSL::ASN1::Enumerated)
              raise Error::PduIdentifierError, "derefAliases of SearchRequest is requested to be Universal Enumerated."
            end
            case @operation.value[2].value.to_i
            when Tag::DerefAliases[:never_deref_aliases]
              @deref_aliases = :never_deref_aliases
            when Tag::DerefAliases[:deref_in_searching]
              @deref_aliases = :deref_in_searching
            when Tag::DerefAliases[:deref_finding_base_obj]
              @deref_aliases = :deref_finding_base_obj
            when Tag::DerefAliases[:deref_always]
              @deref_aliases = :deref_always
            else
              raise RuntimeError, "derefAliases of SearchRequest is requested to be 0 or 1 or 2 or 3."
            end

            unless @operation.value[3].is_a?(OpenSSL::ASN1::Integer)
              raise Error::PduIdentifierError, "sizeLimit of SearchRequest is requested to be Universal Integer."
            end
            @size_limit = @operation.value[3].value.to_i

            unless @operation.value[4].is_a?(OpenSSL::ASN1::Integer)
              raise Error::PduIdentifierError, "timeLimit of SearchRequest is requested to be Universal Integer."
            end
            @time_limit = @operation.value[4].value.to_i

            unless @operation.value[5].is_a?(OpenSSL::ASN1::Boolean)
              raise Error::PduIdentifierError, "typesOnly of SearchRequest is requested to be Universal Boolean."
            end
            @types_only = @operation.value[5].value

            @filter = parse_filter(@operation.value[6])

            unless @operation.value[7].is_a?(OpenSSL::ASN1::Sequence)
              raise Error::PduIdentifierError, "attributes of SearchRequest is requested to be Universal Sequence."
            end
            @attributes = @operation.value[7].map do |attribute|
              unless attribute.is_a?(OpenSSL::ASN1::OctetString)
                raise Error::PduIdentifierError, "Each value of SearchRequest attributes is requested to be Universal OctetString."
              end
              attribute.value
            end
          end

          def parse_filter(pdu)
            unless pdu.tag_class == :CONTEXT_SPECIFIC
              raise Error::PduIdentifierError, "filter of SearchRequest is requested to be Context-specific class ber."
            end
            case pdu.tag
            when Tag::FilterType[:and]
              [:and, parse_sub_filter(pdu)]
            when Tag::FilterType[:or]
              [:or, parse_sub_filter(pdu)]
            when Tag::FilterType[:not]
              [:not, parse_sub_filter(pdu)]
            when Tag::FilterType[:equality_match]
              [:equality_match, parse_attribute_value_assertion(pdu)]
            when Tag::FilterType[:substrings]
              [:substrings, parse_substring_filter(pdu)]
            when Tag::FilterType[:greater_or_equal]
              [:greater_or_equal, parse_attribute_value_assertion(pdu)]
            when Tag::FilterType[:less_or_equal]
              [:less_or_equal, parse_attribute_value_assertion(pdu)]
            when Tag::FilterType[:present]
              [:present, parse_present_filter(pdu)]
            when Tag::FilterType[:approx_match]
              [:approx_match, parse_attribute_value_assertion(pdu)]
            when Tag::FilterType[:extensible_match]
              [:extensible_match, parse_matching_rule_assertion(pdu)]
            else
              raise RuntimeError, "Receive unknown filter type."
            end
          end

          # Use to extract individial filter from and, or, not filter
          def parse_sub_filter(pdu)
            unless pdu.value.is_a?(Array)
              raise Error::PduIdentifierError, "'and', 'or', 'not' Filter is requested to be constructed class ber."
            end
            pdu.value.map do |f|
              parse_filter(f)
            end
          end

          def parse_present_filter(pdu)
            if pdu.value.is_a?(Array)
              raise Error::PduIdentifierError, "present filter is requested to be Primitive ber."
            end

            pdu.value
          end

          def parse_substring_filter(pdu)
            unless pdu.value.is_a?(Array)
              raise Error::PduIdentifierError, "SubstringFilter is requested to be constructed ber."
            end

            unless pdu.value[0].is_a?(OpenSSL::ASN1::OctetString)
              raise Error::PduIdentifierError, "type of SubstringFilter is requested to be Universal OctetString."
            end
            type = pdu.value[0].value

            unless pdu.value[1].valu.is_a?(OpenSSL::ASN1::OctetString)
              raise Error::PduIdentifierError, "substrings of SubstringFilter is requested to be Universal Sequence."
            end
            _initial = false
            _final = false
            substrings = pdu.value[1].value.map do |s|
              unless s.tag_class == :CONTEXT_SPECIFIC
                raise Error::PduIdentifierError, "Each value of SubstringFilter substrings is requested to be Context-specific class ber."
              end

              if s.value.is_a?(Array)
                raise Error::PduIdentifierError, "Each value of SubstringFilter substrings is requested to be Primitive."
              end

              case s.tag
              when Tag::SubstringType[:initial]
                raise RuntimeError, "Tow or more than two initial substrings are in one SubstringFilter." if _initial
                _initial = true
                [:initial, s.value]
              when Tag::SubstringType[:any]
                [:any, s.value]
              when Tag::SubstringType[:final]
                raise RuntimeError, "Tow or more than two final substrings are in one SubstringFilter." if _final
                _final = true
                [:final, s.value]
              else
                raise RuntimeError, "Each value of SubstringFilter substrings tag is requested to be 0 or 1 or 2."
              end
            end

            [type, substrings]
          end

          def parse_matching_rule_assertion(pdu)
            # TODO Implement
            raise RuntimeError, "MatchingRuleAssertion parse is not implemented yet."
          end

          def parse_attribute_value_assertion(pdu)
            unless pdu.value.is_a?(Array)
              raise Error::PduIdentifierError, "AttributeValueAssertion is requested to be constructed ber."
            end

            unless pdu.value.length == 2
              raise Error::PduConstructedLengthError, "The length of AttributeValueAssertion is requested to be exactly 2."
            end

            unless pdu.value.all? do |v|
                v.is_a?(OpenSSL::ASN1::OctetString)
              end
              raise Error::PduIdentifierError, "Each value of AttributeValueAssertion is requested to be Universal OctetString."
            end

            pdu.value.map(&:value)
          end

        end

      end
    end
  end
end
