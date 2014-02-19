require 'openssl'

require (File.dirname(__FILE__) + '/../../spec_helper')
require 'mole/worker/entry'
require 'mole/worker/error'

describe "Mole::Worker::Entry#del" do

  before :all do
    @entry = Mole::Worker::Entry
    @error = Mole::Worker::Error
  end

  before do
    @entry.clear

    @entry.add('dc=example,dc=com',
               [ ['dc', ['example']],
                 ['objectClass', ['organizationalUnit']] ]).should be_true

    @entry.add('ou=People,dc=example,dc=com',
               [ ['ou', ['People']],
                 ['objectClass', ['organizationalUnit']] ]).should be_true

    @entry.add('uid=sato,ou=People,dc=example,dc=com',
               [ ['uid', ['sato']],
                 ['uidNumber', ['10001']],
                 ['objectClass', ['posixAccount', 'inetOrgPerson']] ]).should be_true

    @entry.add('uid=suzuki,ou=People,dc=example,dc=com',
               [ ['uid', ['suzuki']],
                 ['uidNumber', ['10002']],
                 ['objectClass', ['posixAccount', 'inetOrgPerson']] ]).should be_true

    @entry.add('ou=Group,dc=example,dc=com',
               [ ['ou', ['Group']],
                 ['objectClass', ['organizationalUnit']] ]).should be_true

    @entry.add('gid=users,ou=Group,dc=example,dc=com',
               [ ['gid', ['users']],
                 ['objectClass', ['posixGroup']] ]).should be_true
  end

  it "should delete leaf dn." do
    filter = [:present, 'objectClass']
    scope = :whole_subtree
    attributes = []
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
    @entry.del('uid=suzuki,ou=People,dc=example,dc=com').should be_true
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 5
  end

  it "should fail unless specified dn is a leaf." do
    filter = [:present, 'objectClass']
    scope = :whole_subtree
    attributes = []
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
    proc {
      @entry.del('ou=People,dc=example,dc=com').should be_true
    }.should raise_error(@error::NotAllowedOnNonLeafError)
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
  end

  it "should fail unless specified dn is not." do
    filter = [:present, 'objectClass']
    scope = :whole_subtree
    attributes = []
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
    proc {
      @entry.del('uid=katoou=People,dc=example,dc=com').should be_true
    }.should raise_error(@error::NoSuchObjectError)
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
  end

  it "should succeed after all leaves are deleted." do
    filter = [:present, 'objectClass']
    scope = :whole_subtree
    attributes = []
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
    @entry.del('uid=sato,ou=People,dc=example,dc=com').should be_true
    @entry.del('uid=suzuki,ou=People,dc=example,dc=com').should be_true
    @entry.del('ou=People,dc=example,dc=com').should be_true
    @entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 3
  end

end
