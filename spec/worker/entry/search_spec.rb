require 'openssl'

require (File.dirname(__FILE__) + '/../../spec_helper')
require 'mock/ldap/worker/response/entry'
require 'mock/ldap/worker/response/error'

describe "Mock::Ldap::Worker::Response::Entry#search" do

  before :all do
    @response = Mock::Ldap::Worker::Response
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
                           ['objectClass', ['posixAccount', 'inetOrgPerson']] ]).should be_true

    @response::Entry.add('uid=suzuki,ou=People,dc=example,dc=com',
                         [ ['uid', ['suzuki']],
                           ['uidNumber', ['10002']],
                           ['objectClass', ['posixAccount', 'inetOrgPerson']] ]).should be_true

    @response::Entry.add('ou=Group,dc=example,dc=com',
                         [ ['ou', ['Group']],
                           ['objectClass', ['organizationalUnit']] ]).should be_true

    @response::Entry.add('gid=users,ou=Group,dc=example,dc=com',
                         [ ['gid', ['users']],
                           ['objectClass', ['posixGroup']] ]).should be_true
  end

  it "should fail if basedn is not added." do
    @response::Entry.clear
    proc {
      @response::Entry.search('dc=example,dc=com', :base_object, [], [:present, 'objectClass'])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should hit all entries under specified base object when scope is :wholeSubtree." do
    scope = :whole_subtree
    attributes = []
    filter = [:present, 'objectClass']
    @response::Entry.search('dc=com', scope, attributes, filter).length.should == 6
    @response::Entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 6
    @response::Entry.search('ou=People,dc=example,dc=com', scope, attributes, filter).length.should == 3
    @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, attributes, filter).length.should == 1
  end

  it "should fail if base object is not subtree of basedn." do
    proc {
      @response::Entry.search('dc=sample,dc=com', :single_level, [], [:present, 'objectClass'])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should fail if no entry is hit." do
    proc {
      @response::Entry.search('dc=tanaka,ou=People,dc=example,dc=com', :base_object, [], [:present, 'objectClass'])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should hit at most one entry if scope is :base_object." do
    scope = :base_object
    attributes = []
    filter = [:present, 'objectClass']
    proc {
      @response::Entry.search('dc=com', scope, attributes, filter)
    }.should raise_error(@response::NoSuchObjectError)
    @response::Entry.search('dc=example,dc=com', scope, attributes, filter).length.should == 1
    @response::Entry.search('ou=People,dc=example,dc=com', scope, attributes, filter).length.should == 1
    @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, attributes, filter).length.should == 1
  end

  it "should hit itself and its first level children if scope is :single_level." do
    scope = :single_level
    filter = [:present, 'objectClass']
    @response::Entry.search('dc=example,dc=com', scope, [], filter).length.should == 3
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], filter).length.should == 3
    @response::Entry.search('ou=Group,dc=example,dc=com', scope, [], filter).length.should == 2
    @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, [], filter).length.should == 1
  end

  it "should response attributes only specified." do
    scope = :base_object
    filter = [:present, 'objectClass']
    @response::Entry.search('dc=example,dc=com', scope, [], filter)[0].attributes.should be_empty
    entry = @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, ['uid', 'bar'], filter)[0]
    entry.attributes['uid'].should == ['sato']
    entry.attributes['bar'].should be_nil
    entry.attributes['objectClass'].should be_nil
  end

  it "should filter with present filter." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:present, 'uid']).length.should == 2
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:present, 'objectClass']).length.should == 3
    @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, [], [:present, 'uid']).length.should == 1
    proc {
      @response::Entry.search('dc=example,dc=com', scope, [], [:present, 'bar'])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should filter with equality match." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:equality_match, ['objectClass', 'posixAccount']]).length.should == 2
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:equality_match, ['uid', 'sato']]).length.should == 1
    proc {
      @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:equality_match, ['uid', 'tanaka']])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should filter with substring match." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:substrings, ['objectClass', [[:initial, 'posix']]]]).length.should == 3
    @response::Entry.search('dc=example,dc=com', scope, [], [:substrings, ['objectClass', [[:initial, 'posix'], [:final, 'ount']]]]).length.should == 2
    @response::Entry.search('dc=example,dc=com', scope, [], [:substrings, ['ou', [[:any, 'o']]]]).length.should == 2
    @response::Entry.search('dc=example,dc=com', scope, [], [:substrings, ['uid', [[:final, 'ki']]]]).length.should == 1
    proc {
      @response::Entry.search('dc=example,dc=com', scope, [], [:substrings, ['foo', [[:any, 'bar']]]])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should filter with greaterOrEqual match." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:greater_or_equal, ['uidNumber', '10001']]).length.should == 2
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:greater_or_equal, ['uidNumber', '10002']]).length.should == 1
    proc {
      @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:greater_or_equal, ['uidNumber', '10003']])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should filter with lessOrEqual match." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:less_or_equal, ['uidNumber', '10002']]).length.should == 2
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:less_or_equal, ['uidNumber', '10001']]).length.should == 1
    proc {
      @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:less_or_equal, ['uidNumber', '10000']])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should treat approxMathch filter as equalityMatch." do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:approx_match, ['objectClass', 'posixAccount']]).length.should == 2
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:approx_match, ['uid', 'sato']]).length.should == 1
    proc {
      @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:approx_match, ['uid', 'tanaka']])
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should treat extensible_match" do
    scope = :whole_subtree
    @response::Entry.search('dc=example,dc=com', scope, [], [:extensible_match, [:equality_match, 'objectClass', 'posixGroup']]).length.should == 1
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:extensible_match, [:equality_match, nil, 'posixAccount']]).length.should == 2
    @response::Entry.search('dc=example,dc=com', scope, [], [:extensible_match, [nil, 'objectClass', 'organizationalUnit']]).length.should == 3
  end

  it "should treat and filter." do
    scope = :whole_subtree
    filter1 = [:present, 'objectClass']
    filter2 = [:greater_or_equal, ['uidNumber', '10002']]
    filter = [:and, [filter1, filter2]]
    @response::Entry.search('dc=example,dc=com', scope, [], filter).length.should == 1
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], filter).length.should == 1
    proc {
      @response::Entry.search('ou=Group,dc=example,dc=com', scope, [], filter)
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should treat or filter." do
    scope = :whole_subtree
    filter1 = [:equality_match, ['objectClass', 'organizationalUnit']]
    filter2 = [:greater_or_equal, ['uidNumber', '10002']]
    filter = [:or, [filter1, filter2]]
    @response::Entry.search('dc=example,dc=com', scope, [], filter).length.should == 4
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], filter).length.should == 2
    proc {
      @response::Entry.search('uid=sato,ou=People,dc=example,dc=com', scope, [], filter)
    }.should raise_error(@response::NoSuchObjectError)
  end

  it "should treat not filter." do
    scope = :whole_subtree
    proc {
      @response::Entry.search('dc=example,dc=com', scope, [], [:not, [:present, 'objectClass']])
    }.should raise_error(@response::NoSuchObjectError)
    @response::Entry.search('ou=People,dc=example,dc=com', scope, [], [:not, [:present, 'ou']]).length.should == 2
  end

  it "should ignore case to filter." do
    scope = :whole_subtree
    filter = [:present, 'objectclass']
    @response::Entry.search('dc=example,dc=com', scope, [], filter).length.should == 6
  end

  it "should ignore case to matching dn." do
    scope = :whole_subtree
    filter = [:present, 'objectclass']
    @response::Entry.search('dc=Example,dc=Com', scope, [], filter).length.should == 6
  end
end
