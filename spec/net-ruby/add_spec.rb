require (File.dirname(__FILE__) + '/../spec_helper')
require 'net/ldap'

describe "Net::LDAP#add" do

  before :all do
    @server = Mock::Ldap::Server.new(level: 'error')
    @t = @server.listen(async=true)
  end

  before do
    @server.clear
    @ldap = Net::LDAP.new
    @ldap.port = 3890
    @ldap.base = 'dc=example,dc=com'
  end

  after :all do
    @server.close
    @t.join
  end

  it "should be succeeded." do
    @ldap.open { |ldap|
      dn = 'dc=example,dc=com'
      attributes = {dc: 'example', objectClass: ['oaganizationalUnit']}
      ldap.add(dn: dn, attributes: attributes).should be_true

      dn = 'ou=People,dc=example,dc=com'
      attributes = {ou: 'People', objectClass: ['organizationalUnit']}
      ldap.add(dn: dn, attributes: attributes).should be_true

      dn = 'uid=sato,ou=People,dc=example,dc=com'
      attributes = {uid: 'sato', objectClass: ['posixAccont']}
      ldap.add(dn: dn, attributes: attributes).should be_true
    }
  end

  it "should fail when duplicated dn is added." do
    @ldap.open { |ldap|
      dn = 'dc=example,dc=com'
      attributes = {dc: 'example', objectClass: ['oaganizationalUnit']}
      ldap.add(dn: dn, attributes: attributes).should be_true
      ldap.add(dn: dn, attributes: attributes).should be_false
    }
  end

  it "should fail when added dn is not subtree of the base dn." do
    @ldap.open { |ldap|
      dn = 'dc=example,dc=com'
      attributes = {dc: 'example', objectClass: ['oaganizationalUnit']}
      ldap.add(dn: dn, attributes: attributes).should be_true


      dn = 'dc=samle,dc=com'
      attributes = {dc: 'sample', objectClass: ['oaganizationalUnit']}
      ldap.add(dn: dn, attributes: attributes).should be_false
    }
  end

end
