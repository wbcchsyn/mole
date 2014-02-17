module Mock
  module Ldap
    module Worker
      module Tag

        # See RFC4511 Appendix B.
        Application = {
          :BindRequest => 0,
          :BindResponse => 1,
          :UnbindRequest => 2,
          :SearchRequest => 3,
          :SearchResultEntry => 4,
          :SearchResultDone => 5,
          :ModifyRequest => 6,
          :ModifyResponse => 7,
          :AddRequest => 8,
          :AddResponse => 9,
          :DelRequest => 10,
          :DelResponse => 11,
          :ModifyDNRequest => 12,
          :ModifyDNResponse => 13,
          :CompareRequest => 14,
          :CompareResponse => 15,
          :AbandonRequest => 16,
          :SearchResultReference => 19,
          :ExtendedRequest => 23,
          :ExtendedResponse => 24,
          :IntermediateResponse => 25,
        }

        Context_Specific = {
          # See RFC4511 section 4.2
          :AuthenticationChoice => {
            :simple => 0,
            :sasl => 3,
          },
        }

        # See RFC4511 Section 4.5.1
        Scope = {
          :base_object => 0,
          :single_level => 1,
          :whole_subtree => 2,
        }

        # See RFC4511 Section 4.5.1
        DerefAliases = {
          :never_deref_aliases => 0,
          :deref_in_searching => 1,
          :deref_finding_base_obj => 2,
          :deref_always => 3,
        }

        SubstringType = {
          :initial => 0,
          :any => 1,
          :final => 2,
        }

        FilterType = {
          :and => 0,
          :or => 1,
          :not => 2,
          :equality_match => 3,
          :substrings => 4,
          :greater_or_equal => 5,
          :less_or_equal => 6,
          :present => 7,
          :approx_match => 8,
          :extensible_match => 9,
        }

        ChangesOperation = {
          :add => 0,
          :delete => 1,
          :replace => 2,
        }
      end
    end
  end
end
