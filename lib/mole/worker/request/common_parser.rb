 require 'openssl'

 require 'mole/worker/error'

 module Mole
   module Worker
     module Request
       extend Mole::Worker::Error


       def sanitize_constructed(pdu, subject)
         unless pdu.value.is_a?(Array)
           message = "#{subject} is requested to be Constructed ber."
           raise Error::ProtocolError, message
         end
         pdu
       end

       def sanitize_primitive(pdu, subject)
         if pdu.value.is_a?(Array)
           message = "#{subject} is requested to be Primitive ber."
           raise Error::ProtocolError, message
         end
       end

       def sanitize_length(pdu, length, subject)
         sanitize_constructed(pdu, subject)
         unless pdu.value.length == length
           message = "The length of #{subject} is requested to be exactly #{length}."
           raise Error::ProtocolError, message
         end
         pdu
       end

       def sanitize_class(pdu, tag_class, subject)
         unless pdu.tag_class == tag_class
           message = "#{subject} is requested to be #{tag_class.to_s.capitalize} class ber."
           raise Error::ProtocolError, message
         end
         pdu
       end

       module_function :sanitize_constructed, :sanitize_primitive, :sanitize_length, :sanitize_class

       def parse_sequence(pdu, subject)
         unless pdu.is_a?(OpenSSL::ASN1::Sequence)
           message = "#{subject} is requested to be Universal SEQUENCE ber."
           raise Error::ProtocolError, message
         end
         pdu.value
       end

       def parse_octet_string(pdu, subject)
         unless pdu.is_a?(OpenSSL::ASN1::OctetString)
           message = "#{subject} is requested to be Universal OCTET STRING ber."
           raise Error::ProtocolError, message
         end
         pdu.value
       end

       def parse_integer(pdu, subject)
         unless pdu.is_a?(OpenSSL::ASN1::Integer)
           message = "#{subject} is requested to be Universal INTEGER ber."
           raise Error::ProtocolError, message
         end
         pdu.value.to_i
       end

       def parse_enumerated(pdu, subject)
         unless pdu.is_a?(OpenSSL::ASN1::Enumerated)
           message = "#{subject} is requested to be Universal ENUMERATED ber."
           raise Error::ProtocolError, message
         end
         pdu.value.to_i
       end

       def parse_boolean(pdu, subject)
         unless pdu.is_a?(OpenSSL::ASN1::Boolean)
           message = "#{subject} is requested to be Universal BOOLEAN ber."
           raise Error::ProtocolError, message
         end
         pdu.value
       end

       module_function :parse_sequence, :parse_octet_string, :parse_integer, :parse_enumerated, :parse_boolean

       # See RFC4511 Section 4.1.3
       def parse_ldap_dn(pdu, subject)
         ldap_dn = parse_octet_string(pdu, subject)

         unless ldap_dn.empty? or ldap_dn =~ /^\w+=\w+(,\w+=\w+)*$/
           raise Error::InvalidDNSyntaxError, "#{ldap_dn} is not legal as LDAP DN."
         end

         ldap_dn
       end

       # See RFC4511 Section 4.1.7
       def parse_attribute(pdu)
         type, vals = parse_partial_attribute(pdu)

         if vals.empty?
           raise Error::ProtocolError, "vals of Attribute should not be empty."
         end

         [type, vals]
       end

       # See RFC4511 Section 4.1.7
       def parse_partial_attribute(pdu)
         unless pdu.is_a?(OpenSSL::ASN1::Sequence)
           raise Error::ProtocolError, "Attribute and PartialAttribute is requested to be Universal Sequence."
         end

         unless pdu.value.length == 2
           raise Error::ProtocolError, "The length of Attribute or PartialAttribute is requested to be exactrly 2."
         end

         unless pdu.value[0].is_a?(OpenSSL::ASN1::OctetString)
           raise Error::ProtocolError, "type of Attribute or PartialAttribute is requested to be Universal OctetString."
         end
         type = pdu.value[0].value

         unless pdu.value[1].is_a?(OpenSSL::ASN1::Set)
           raise Error::ProtocolError, "vals of Attribute or PartialAttribute is requested to be Universal Set."
         end
         vals = pdu.value[1].value.map do |val|
           # Some ldap tools may send UniversalInteger and so on.
           # However, it should be OctetString according to RFC
           unless val.is_a?(OpenSSL::ASN1::OctetString)
             raise Error::ProtocolError, "Each value of Attribute or PartialAttribute vals is requested to be Universal OctetString."
           end
           val.value
         end

         [type, vals]
       end

       module_function :parse_ldap_dn, :parse_attribute, :parse_partial_attribute


     end
   end
end
