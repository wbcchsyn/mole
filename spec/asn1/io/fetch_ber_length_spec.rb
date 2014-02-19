require (File.dirname(__FILE__) + '/../../spec_helper')
require 'openssl'

describe "Mole::Asn1::IO#fetch_ber_length" do

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

  it "should read length when the length is short form." do
    length = 0x79
    s = ''
    s.encode!('ASCII-8BIT')
    s << length

    @w.write(s)
    @w.write('abc')
    @r.send(:fetch_ber_length).should == [length, s]
  end

  it "should read length when the length is long form." do
    length = 0x80
    s = ''
    s.encode!('ASCII-8BIT')
    s << (0x80 | 0x01)
    s << length

    @w.write(s)
    @w.write('abc')
    @r.send(:fetch_ber_length).should == [length, s]
  end
end
