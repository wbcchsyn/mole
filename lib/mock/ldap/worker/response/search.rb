require 'mock/ldap/worker/response/abst_response'
require 'mock/ldap/worker/response/Entry'

module Mock
  module Ldap
    module Worker
      module Response

        class Search < AbstResponse

          def initialize(request)
            @protocol = :SearchResultDone
            @matched_dn = request.base_object
            @diagnostic_message = "Search #{request.base_object} #{request.scope} #{request.attributes}."
            super
          end

          def to_pdu
            if @entries
              results = @entries.map do |entry|
                create_ldap_message(create_search_result_entry(entry))
              end

              results + super
            else
              super
            end
          end

          private

          def execute
            @entries = Entry.search(@request.base_object, @request.scope, @request.attributes, @request.filter)
          end

          def create_search_result_entry(entry)
            dn = OpenSSL::ASN1::OctetString.new(entry.dn)
            _attrs = entry.attributes.map do |k, v|
              create_partial_attribute(k, v)
            end
            attributes = OpenSSL::ASN1::Sequence.new(_attrs)

            OpenSSL::ASN1::Sequence.new([dn, attributes],
                                        tag=Tag::Application[:SearchResultEntry],
                                        tagging=:IMPLICIT,
                                        tag_class=:APPLICATION)
          end

          def create_partial_attribute(type, values)
            _vals = values.map do |v|
              OpenSSL::ASN1::OctetString.new(v)
            end
            OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::OctetString.new(type), OpenSSL::ASN1::Set.new(_vals)])
          end

        end
      end
    end
  end
end
