require 'openssl'

require (File.dirname(__FILE__) + '/../../spec_helper')
require 'mock/ldap/worker/response/entry'
require 'mock/ldap/worker/response/error'

describe "Mock::Ldap::Worker::Response::Entry#add" do

  before :all do
    @response =  Mock::Ldap::Worker::Response
  end

  before do
    @response::Entry.clear
  end

  it "should succeed to add basedn and child entries." do
    @response::Entry.add('dc=sample,dc=com',
                         [ ['dc', ['sample']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    @response::Entry.add('ou=People,dc=sample,dc=com',
                         [ ['ou', ['People']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    @response::Entry.add('uid=sato,ou=People,dc=sample,dc=com',
                         [ ['uid', ['sato']],
                           ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
    @response::Entry.add('ou=Group,dc=sample,dc=com',
                         [ ['ou', ['Group']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    @response::Entry.add('gid=users,ou=Group,dc=sample,dc=com',
                         [ ['gid', ['users']],
                           ['objectClass', ['posixGroup']] ]).should be_true
    @response::Entry.add('uid=suzuki,ou=People,dc=sample,dc=com',
                         [ ['uid', ['suzuki']],
                           ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
  end

  it "should fail to add duplicated entries." do
    @response::Entry.add('dc=sample,dc=com',
                         [ ['dc', ['sample']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @response::Entry.add('dc=sample,dc=com',
                           [ ['dc', ['sample']],
                             ['objectclass', ['organizationalUnit']] ]).should be_true
    }.should raise_error(@response::EntryAlreadyExistsError)
    @response::Entry.add('ou=People,dc=sample,dc=com',
                         [ ['ou', ['People']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @response::Entry.add('ou=People,dc=sample,dc=com',
                           [ ['ou', ['People']],
                             ['objectclass', ['organizationalUnit']] ]).should be_true
    }.should raise_error(@response::EntryAlreadyExistsError)
  end

  it "should fail if parent dn doesn't exist." do
    @response::Entry.add('dc=sample,dc=com',
                         [ ['dc', ['sample']],
                           ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @response::Entry.add('uid=sato,ou=People,dc=sample,dc=com',
                           [ ['uid', ['sato']],
                             ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
    }.should raise_error(@response::UnwillingToPerformError)
  end
end
