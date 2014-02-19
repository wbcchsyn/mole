require (File.dirname(__FILE__) + '/../../spec_helper')
require 'openssl'

describe "Mole::Asn1::IO#fetch_ber" do

  before do
    @r, @w = IO.pipe
    class << @r
      include Mole::Asn1::IO
    end
  end

  after do
    @w.close unless @w.closed?
    @r.close unless @r.closed?
  end

  it "should read just one ber string." do
    ber = OpenSSL::ASN1::Integer(5).to_der
    @w.write(ber)
    @w.write('abc')
    @r.fetch_ber.should == ber
  end

  it "should read sequence ber." do
    i = OpenSSL::ASN1::Integer.new(3)
    o = OpenSSL::ASN1::OctetString.new('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    ber = OpenSSL::ASN1::Sequence.new([i, o]).to_der

    @w.write(ber)
    @w.write('abcde')
    @r.fetch_ber.should == ber
  end

  it "should read long form ber." do
    ber = OpenSSL::ASN1::ASN1Data.new('abc', tag=31, tag_class=:APPLICATION).to_der
    @w.write(ber)
    @w.write('ccccc')
    @r.fetch_ber.should == ber
  end

  it "should read indefinite length ber." do
    ber = ''
    ber.encode!('ASCII-8BIT')

    ber << 0x30 # Universal Sequence tag
    ber << 0x80 # indefinite length
    ber << OpenSSL::ASN1::Integer.new(3).to_der
    ber << OpenSSL::ASN1::OctetString.new('bar').to_der
    ber << OpenSSL::ASN1::EOC

    @w.write(ber)
    @w.write('beiw')
    @r.fetch_ber.should == ber
  end
end
