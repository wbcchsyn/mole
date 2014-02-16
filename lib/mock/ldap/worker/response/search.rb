require 'mock/ldap/worker/response/pdu'
require 'mock/ldap/worker/response/error'
require 'mock/ldap/worker/response/Entry'
require 'mock/ldap/worker/tag'

module Mock
  module Ldap
    module Worker
      module Response

        class Search
          include Pdu
          extend Mock::Ldap::Worker::Tag

          def initialize(request)
            @protocol = :SearchResultDone
            @message_id = request.message_id
            @matched_dn = sanitize_dn(request.base_object)
            @entries = Entry.search(request.base_object, request.scope, request.attributes, request.filter)
            @result = :success
            @diagnostic_message = "#{@entries.length} entries are hit."
          rescue Error
            @result = $!.code
            @diagnostic_message = $!.message
          end

          def to_pdu
            if @entries
              results = @entries.map do |entry|
                create_ldap_message(@message_id,
                                    create_search_result_entry(entry))
              end

              results << super
            else
              super
            end
          end

          private

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
