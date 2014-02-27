# Mole

Mole is a schemaless Mock LDAP server implemented Ruby.

## Requirements

* Ruby 2.0

## Test

* Ruby 2.0.0p353 Mac OSX

## Usage

### Use as a ruby gem.

TODO: Write usage instructions here

### Use Directory

1. git clone https://github.com/wbcchsyn/mole.git
1. cd mole
1. ruby mole [options]
1. git clone https://github.com/wbcchsyn/mole.git
1. cd mole
1. ruby mole [options]
  The following options are available.
    1. --host HOST: Host to be listened. Default is 127.0.0.1.
    1. --port PORT: Port to listen. Default is 3890.
    1. --log FILE: Path to log file. Default is stdout.
    1. --level LEVEL: Log level. It must be debug or info or warn or error or fatal. Default is info.

## Specification

* Neither ssl nor tls protocol is supported.
* Response to the following requests.
  * BindRequest  
    Only simple auth is supported. It always succeed without checking bind dn and password.
  * AddRequest  
    The first entry to be added will be base dn.
  * SearchRequest  
    extensibleMatch filter is left to be implemented.
  * ModifyRequest
  * ModifyDNRequest
  * DelRequest
  * UnBindRequest
* Ruby ActiveLdap module doesn't work so far.
* Ruby net-ldap module seems to work.
* Linux LDAP tools (ldapadd, ldapsearch, ldapmodify, ldapdelete) seems to work.
