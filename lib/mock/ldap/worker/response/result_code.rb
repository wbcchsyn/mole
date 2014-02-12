module Mock
  module Ldap
    module Worker
      module Response

        RESULT_CODE = {
          success: 0,
          operationsError: 1,
          protocolError: 2,
          timeLimitExceeded: 3,
          sizeLimitExceeded: 4,
          compareFalse: 5,
          compareTrue: 6,
          authMethodNotSupported: 7,
          strongerAuthRequired: 8,
          referral: 10,
          adminLimitExceeded: 11,
          unavailableCriticalExtension: 12,
          confidentialityRequired: 13,
          saslBindInProgress: 14,
          noSuchAttribute: 16,
          undefinedAttributeType: 17,
          inappropriateMatching: 18,
          constraintViolation: 19,
          attributeOrValueExists: 20,
          invalidAttributeSyntax: 21,
          noSuchObject: 32,
          aliasProblem: 33,
          invalidDNSyntax: 34,
          aliasDereferencingProblem: 36,
          inappropriateAuthentication: 48,
          invalidCredentials: 49,
          insufficientAccessRights: 50,
          busy: 51,
          unavailable: 52,
          unwillingToPerform: 53,
          loopDetect: 54,
          namingViolation: 64,
          objectClassViolation: 65,
          notAllowedOnNonLeaf: 66,
          notAllowedOnRDN: 67,
          entryAlreadyExists: 68,
          objectClassModsProhibited: 69,
          affectsMultipleDSAs: 71,
          other: 80,
        }

      end
    end
  end
end
