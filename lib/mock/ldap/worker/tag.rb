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

      end
    end
  end
end
