require (File.dirname(__FILE__) + '/../spec_helper')
require 'net/ldap'

describe "Net::LDAP#delete" do

  before :all do
    @server = Mole::Server.new(level: 'error')
    @t = @server.listen(async=true)

  end

  before do
    @server.clear

    @ldap = Net::LDAP.new
    @ldap.port = 3890
    @ldap.base = 'dc=example,dc=com'

    @ldap.open do |ldap|
      ldap.add(dn: 'dc=example,dc=com',
               attributes: {dc: "example", objectClass: "organizationalUnit"})
      ldap.add(dn: 'ou=Group,dc=example,dc=com',
               attributes: {ou: "Group", objectClass: "organizationalUnit"})
      ldap.add(dn: 'gid=userf,ou=Group,dc=example,dc=com',
               attributes: {gid: "users", objectClass: "posixGroup", gidNumber: '10001'})
      ldap.add(dn: 'ou=People,dc=example,dc=com',
               attributes: {ou: "People", objectClass: "organizationalUnit"})
      ldap.add(dn: 'uid=sato,ou=People,dc=example,dc=com',
               attributes: {uid: "sato", objectClass: ['posixAccount', 'inetOrgPerson'], uidNumber: '10001', gidNumber: '10001'})
      ldap.add(dn: 'uid=suzuki,ou=People,dc=example,dc=com',
               attributes: {uid: "suzuki", objectClass: ['posixAccount', 'inetOrgPerson'], uidNumber: '10002', gidNumber: '10002'})
    end
  end

  after :all do
    @server.close
    @t.join
  end

  it "should succeed to delete leaf dn." do
    @ldap.open do |ldap|
      ldap.search(base: 'dc=example,dc=com').length.should == 6
      ldap.delete(dn: 'uid=sato,ou=People,dc=example,dc=com').should be_true
      ldap.search(base: 'dc=example,dc=com').length.should == 5
    end
  end

  it "should fail to delete not leaf dn." do
    @ldap.open do |ldap|
      ldap.search(base: 'dc=example,dc=com').length.should == 6
      ldap.delete(dn: 'ou=People,dc=example,dc=com').should be_false
      ldap.search(base: 'dc=example,dc=com').length.should == 6
    end
  end

  it "should succeed to delete not leaf dn after all child dn is deleted." do
    @ldap.open do |ldap|
      ldap.search(base: 'dc=example,dc=com').length.should == 6
      ldap.delete(dn: 'uid=sato,ou=People,dc=example,dc=com').should be_true
      ldap.delete(dn: 'uid=suzuki,ou=People,dc=example,dc=com').should be_true
      ldap.delete(dn: 'ou=People,dc=example,dc=com').should be_true
      ldap.search(base: 'dc=example,dc=com').length.should == 3
    end
  end

  it "should fail to delete not existed entry." do
    @ldap.open do |ldap|
      ldap.search(base: 'dc=example,dc=com').length.should == 6
      ldap.delete(dn: 'uid=kato,ou=People,dc=example,dc=com').should be_false
      ldap.search(base: 'dc=example,dc=com').length.should == 6
    end
  end

end
