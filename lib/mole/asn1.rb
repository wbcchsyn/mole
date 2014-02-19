require 'mole/asn1/io'

module Mole
  module Asn1


    def pp_pdu(pdu)
      raise TypeError, "Argument pdu is requested to be OpenSSL::ASN1::ASN1Data." unless pdu.is_a?(OpenSSL::ASN1::ASN1Data)
      header = "<#{pdu.tag_class.to_s[0]},#{pdu.tag}>"
      if pdu.value.is_a?(OpenSSL::BN)
        data = pdu.value.to_i
      elsif pdu.value.is_a?(Array)
        data = '[' + pdu.value.map { |v| pp_pdu(v)}.join(', ') + ']'
      else
        data = pdu.value
      end

      "#{header}#{data}"
    end

    module_function :pp_pdu


  end
end
