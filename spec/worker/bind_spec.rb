require 'openssl'

require (File.dirname(__FILE__) + '/../spec_helper')
require 'mock/ldap/worker'

describe "Mock::Ldap::Worker#handle" do

  it "should be succeeded with annonymous simple auth." do
    message_id = 1
    version = 3
    name = ''
    auth = ''

    message_id_pdu = OpenSSL::ASN1::Integer.new(message_id)
    version_pdu = OpenSSL::ASN1::Integer.new(version)
    name_pdu = OpenSSL::ASN1::OctetString.new(name)
    auth_pdu = OpenSSL::ASN1::OctetString.new(auth,
                                              tag=Mock::Ldap::Worker::Tag::AuthenticationChoice[:simple],
                                              tagging=:IMPLICIT,
                                              tag_class=:CONTEXT_SPECIFIC)

    bind_request = OpenSSL::ASN1::Sequence.new([version_pdu, name_pdu, auth_pdu],
                                               tag=Mock::Ldap::Worker::Tag::Application[:BindRequest],
                                               tagging=:IMPLICIT,
                                               tag_class=:APPLICATION)
    send_pdu = OpenSSL::ASN1::Sequence.new([message_id_pdu, bind_request])

    request, response = Mock::Ldap::Worker.handle(send_pdu)
    response.message_id.should == message_id
    response.result.should == :success
    response.matched_dn.should == name
  end

  it "should be succeeded with any dn simple auth." do
    message_id = 2
    version = 3
    name = 'uid=AliBaba,dc=example,dc=com'
    auth = 'open sesami'

    message_id_pdu = OpenSSL::ASN1::Integer.new(message_id)
    version_pdu = OpenSSL::ASN1::Integer.new(version)
    name_pdu = OpenSSL::ASN1::OctetString.new(name)
    auth_pdu = OpenSSL::ASN1::OctetString.new(auth,
                                              tag=Mock::Ldap::Worker::Tag::AuthenticationChoice[:simple],
                                              tagging=:IMPLICIT,
                                              tag_class=:CONTEXT_SPECIFIC)

    bind_request = OpenSSL::ASN1::Sequence.new([version_pdu, name_pdu, auth_pdu],
                                               tag=Mock::Ldap::Worker::Tag::Application[:BindRequest],
                                               tagging=:IMPLICIT,
                                               tag_class=:APPLICATION)
    send_pdu = OpenSSL::ASN1::Sequence.new([message_id_pdu, bind_request])

    request, response = Mock::Ldap::Worker.handle(send_pdu)
    response.message_id.should == message_id
    response.result.should == :success
    response.matched_dn.should == name
  end

end
