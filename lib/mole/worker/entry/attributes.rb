require 'mole/worker/error'

module Mole
  module Worker
    module Entry


      class Attributes < IgnoreCaseHash

        def self.[](attributes)
          ret = new

          attributes.each do |attr|
            unless attr.length == 2
              raise ArgumentError, "invalid number of elements. (#{attr.length} for 2)"
            end

            type = attr[0]
            vals = attr[1]

            unless vals..is_a?(Array)
              raise TypeError, "Each attribute vallues must be Array"
            end

            ret[type] = vals
          end

          ret
        end

        private :initialize

        def select(filter)
          send(*filter)
        end

        private

        def and(filters)
          filters.map { |filter|
            select(filter)
          }.all?
        end

        def or(filters)
          filters.map { |filter|
            select(filter)
          }.any?
        end

        def not(filter)
          not select(filter)
        end

        def equality_match(attribute)
          type = attribute[0]
          value = attribute[1]

          return false unless has_key?(type)

          self[type].any? do |v|
            v =~ /^#{value}$/i
          end
        end

        def substrings(substring)
          type = substring[0]

          substring[1].map { |sub|
            position = sub[0]
            value = sub[1]

            return false unless has_key?(type)
            case position
            when :initial
              self[type].any? do |v| v =~ /^#{value}/i end
            when :any
              self[type].any? do |v| v =~ /#{value}/i end
            when :final
              self[type].any? do |v| v =~ /#{value}$/i end
            end
          }.all?
        end

        def greater_or_equal(attribute)
          type = attribute[0]
          value = attribute[1]

          return false unless has_key?(type)

          self[type].any? do |v|
            v.downcase >= value.downcase
          end
        end

        def less_or_equal(attribute)
          type = attribute[0]
          value = attribute[1]

          return false unless has_key?(type)

          self[type].any? do |v|
            v.downcase <= value.downcase
          end
        end

        def present(type)
          has_key?(type)
        end

        def approx_match(attribute)
          # There is no self approximate matching rule,
          # so behave as equality mathcing according to RFC4511 Section 4.5.1.7.6
          equality_match(attribute)
        end

        def extensible_match(attribute)
          matching_rule = attribute[0]
          type = attribute[1]
          match_value = attribute[2]
          dn_attributes = attribute[3] || false

          if dn_attributes
            # TODO Implement extensible_match when dn_attribute is True
            raise Error::ProtocolError, "extensibleMatch filter rule with dn attributes is not implemented yet."
          end

          if matching_rule and type
            select([matching_rule, [type, match_value]])
          elsif (not matching_rule) and type
            equality_match([type, match_value])
          elsif matching_rule and (not type)
            keys.map { |t|
              select([matching_rule, [t, match_value]])
            }.any?
          else
            raise Error::ProtocolError, "Neither mathingRule nor type is not specified in extensibleMatch filter."
          end
        end
      end

      private_constant :Attributes


    end
  end
end
