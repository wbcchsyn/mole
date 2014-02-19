require 'openssl'

require (File.dirname(__FILE__) + '/../../spec_helper')
require 'mole/worker/response/entry'
require 'mole/worker/error'

describe "Mole::Worker::Response::Entry#add" do

  before :all do
    @entry =  Mole::Worker::Response::Entry
    @error =  Mole::Worker::Error
  end

  before do
    @entry.clear
  end

  it "should succeed to add basedn and child entries." do
    @entry.add('dc=sample,dc=com',
               [ ['dc', ['sample']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    @entry.add('ou=People,dc=sample,dc=com',
               [ ['ou', ['People']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    @entry.add('uid=sato,ou=People,dc=sample,dc=com',
               [ ['uid', ['sato']],
                 ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
    @entry.add('ou=Group,dc=sample,dc=com',
               [ ['ou', ['Group']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    @entry.add('gid=users,ou=Group,dc=sample,dc=com',
               [ ['gid', ['users']],
                 ['objectClass', ['posixGroup']] ]).should be_true
    @entry.add('uid=suzuki,ou=People,dc=sample,dc=com',
               [ ['uid', ['suzuki']],
                 ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
  end

  it "should fail to add duplicated entries." do
    @entry.add('dc=sample,dc=com',
               [ ['dc', ['sample']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @entry.add('dc=sample,dc=com',
                 [ ['dc', ['sample']],
                   ['objectclass', ['organizationalUnit']] ]).should be_true
    }.should raise_error(@error::EntryAlreadyExistsError)
    @entry.add('ou=People,dc=sample,dc=com',
               [ ['ou', ['People']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @entry.add('ou=People,dc=sample,dc=com',
                 [ ['ou', ['People']],
                   ['objectclass', ['organizationalUnit']] ]).should be_true
    }.should raise_error(@error::EntryAlreadyExistsError)
  end

  it "should fail if parent dn doesn't exist." do
    @entry.add('dc=sample,dc=com',
               [ ['dc', ['sample']],
                 ['objectclass', ['organizationalUnit']] ]).should be_true
    proc {
      @entry.add('uid=sato,ou=People,dc=sample,dc=com',
                 [ ['uid', ['sato']],
                   ['objectclass', ['posixAccount', 'inetOrgPerson']] ]).should be_true
    }.should raise_error(@error::UnwillingToPerformError)
  end
end
