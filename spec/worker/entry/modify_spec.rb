require 'openssl'

require (File.dirname(__FILE__) + '/../../spec_helper')
require 'mock/ldap/worker/response/entry'
require 'mock/ldap/worker/response/error'

describe "Mock::Ldap::Worker::Response::Entry#modify" do

  before :all do
    @response = Mock::Ldap::Worker::Response
    @filter = [:present, 'objectClass'] # Hit all entries
  end

  before do
    @response::Entry.clear

    @response::Entry.add('dc=example,dc=com',
                         [ ['dc', ['example']],
                           ['objectClass', ['organizationalUnit']] ]).should be_true

    @response::Entry.add('ou=People,dc=example,dc=com',
                         [ ['ou', ['People']],
                           ['objectClass', ['organizationalUnit']] ]).should be_true

    @response::Entry.add('uid=sato,ou=People,dc=example,dc=com',
                         [ ['uid', ['sato']],
                           ['uidNumber', ['10001']],
                           ['objectClass', ['posixAccount', 'inetOrgPerson'],],
                           ['mail', ['sato@example.com', 'sato@example.net', 'sato@example.org']] ]).should be_true

    @response::Entry.add('uid=suzuki,ou=People,dc=example,dc=com',
                         [ ['uid', ['suzuki']],
                           ['uidNumber', ['10002']],
                           ['objectClass', ['posixAccount', 'inetOrgPerson']],
                           ['mail', ['suzuki@example.com', 'suzuki@example.net', 'suzuki@example.org']] ]).should be_true

    @response::Entry.add('ou=Group,dc=example,dc=com',
                         [ ['ou', ['Group']],
                           ['objectClass', ['organizationalUnit']] ]).should be_true

    @response::Entry.add('gid=users,ou=Group,dc=example,dc=com',
                         [ ['gid', ['users']],
                           ['objectClass', ['posixGroup']] ]).should be_true
  end

  it "should add attributes with add operation." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    mobile = ['000-0000-0000', '111-1111-1111']
    @response::Entry.modify(dn, [[:add, ["mobile", mobile]]])
    @response::Entry.search(dn, :base_object, ["mobile"], @filter)[0].attributes[:mobile].should == mobile

    new_mobile = ['222-2222-2222']
    @response::Entry.modify(dn, [[:add, ["mobile", new_mobile]]])
    @response::Entry.search(dn, :base_object, ["mobile"], @filter)[0].attributes[:mobile].should == mobile + new_mobile
  end

  it "should delete attributes with delete operation." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    @response::Entry.modify(dn, [[:delete, ["mail", ['sato@example.net']]]])
    @response::Entry.search(dn, :base_object, ["mail"], @filter)[0].attributes[:mail].should == ['sato@example.com', 'sato@example.org']
    @response::Entry.modify(dn, [[:delete, ["mail", ['sato@example.org', 'sato@example.com']]]])
    @response::Entry.search(dn, :base_object, ["mail"], @filter)[0].attributes[:mail].should be_nil

    dn = 'uid=suzuki,ou=People,dc=example,dc=com'
    @response::Entry.modify(dn, [[:delete, ["mail", []]]])
    @response::Entry.search(dn, :base_object, ["mail"], @filter)[0].attributes[:mail].should be_nil
  end

  it "shoule fail to delete unexisted attributes." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    proc {
      @response::Entry.modify(dn, [[:delete, ["mail", ['sato@example.biz']]]])
    }.should raise_error(@response::NoSuchAttributeError)

    proc {
      @response::Entry.modify(dn, [[:delete, ["mobile", ['000-0000-0000']]]])
    }.should raise_error(@response::NoSuchAttributeError)

    proc {
      @response::Entry.modify(dn, [[:delete, ["homedirectory", []]]])
    }.should raise_error(@response::NoSuchAttributeError)
  end

  it "should replace attributes with replace operation." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    @response::Entry.modify(dn, [[:replace, ["mail", ['sato@example.info']]]])
    @response::Entry.search(dn, :base_object, ["mail"], @filter)[0].attributes[:mail].should == ['sato@example.info']
    @response::Entry.modify(dn, [[:replace, ["mail", []]]])
    @response::Entry.search(dn, :base_object, ["mail"], @filter)[0].attributes[:mail].should be_nil
    @response::Entry.modify(dn, [[:replace, ["mobile", ['000-0000-0000']]]])
    @response::Entry.search(dn, :base_object, ["mobile"], @filter)[0].attributes[:mobile].should == ['000-0000-0000']
    @response::Entry.modify(dn, [[:replace, ["homedirectory", []]]]) # Check no error is raised.
  end

  it "should treat many operations at once." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    mobile = ['000-0000-0000', '111-1111-1111']
    new_mobile = ['222-2222-2222']
    homedirectory = ['/home/sato']
    new_mail = ['sato@example.biz']
    @response::Entry.modify(dn,
                            [
                              [:add, ["mobile", mobile]],
                              [:add, ["homedirectory", homedirectory]],
                              [:add, ["mail", new_mail]],
                              [:delete, ['mail', []]],
                              [:replace, ["mobile", new_mobile]]
                            ])
    entry = @response::Entry.search(dn, :base_object, ['mail', 'homedirectory', 'mobile'], @filter)[0]
    entry.attributes['mobile'].should == new_mobile
    entry.attributes['homedirectory'].should == homedirectory
    entry.attributes['mail'].should be_nil
  end

  it "should be atomic operation." do
    dn = 'uid=sato,ou=People,dc=example,dc=com'
    mobile = ['000-0000-0000', '111-1111-1111']
    proc {
      @response::Entry.modify(dn,
                              [
                                [:add, ["mobile", mobile]],
                                [:delete, ['homedirectory', []]],
                              ])
    }.should raise_error(@response::NoSuchAttributeError)
    @response::Entry.search(dn, :base_object, ['mail', 'homedirectory', 'mobile'], @filter)[0].attributes['mobile'].should be_nil
  end
end
