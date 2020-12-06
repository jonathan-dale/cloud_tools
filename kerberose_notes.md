#kerberos

### Prerequisites - NTP and DNS must be working first.

SSSD - System Security Services Daemon - talks to LDAP and other identity and auth providers.


#### Configure LDAP Authentication

 DNS is configured to point ot the FreeIPA server.
```bash
[ec2-user@host ~ ]# cat /etc/resolve.conf
search rhce.locla
nameserver 10.8.8.70

# host 10.8.8.70
70.8.8.10.in-addr.arpa domain name pointer ipa.rhce.local.
```


#### Installation
```bash
[ec2-user@host ~ ]# sudo yum install -y sssd nss-pan-ldapd wget
```


#### download the CA cert from the IPA SERVER
```bash
[ec2-user@host ~ ]# mkdir -p /etc/openldap/cacerts
[ec2-user@host ~ ]# wget -P /etc/openldap/cacerts ftp://ipa.rhce.local/pub/cacert.p12
**NOTE-ipa.rhce.local is the hostname
```

#### Configuration
#### Open /etc/sysconfig/authconfig and add this
```bash
USESSSDAUTH=yes
FORCELEGACY=no
USESSSD=yes
```

#### run auth config utility
```bash
[ec2-user@host ~ ]# authconfig-tui
## 'User Information' select 'Use LDAP'
## 'Authentication'   select 'Use LDAP Authenticaiton'
## 'LDAP Settings'    select 'Use TLS' and specify following:
Server: ipa.rhce.local
Bsae DN: dc=rhce,dc=local
```

 add this line to /etc/sssd/sssd.conf (you can also check man sssd-ldap for more options)
```bash
ldap_tls_reqcert = never
```

#### disable 'nslcd' and enable 'sssd'
```bash
[ec2-user@host ~ ]# systemctl stop nslcd; systemctl disable nslcd
[ec2-user@host ~ ]# systemctl enable sssd; systemctl restart sssd
```


#### verify by loging in with an LDAP user
```bash
[ec2-user@host ~ ]# su - alice
su: warning: cannot change directory to /home/alice: No such file or directory
$ id
uid=1219400005(alice) gid=121940005(alice) groups-121940005(alice) context=unconfined_u:unconfined_r:unconfined_t:s0:c0:c1023
```


### Configure Kerberos Authentication

#### Installation

```bash
[ec2-user@host ~ ]# yum install -y pam_krb5-workstation
```

#### Configuration erace /etc/krb5.conf when configuring from scratch

```bash
[ec2-user@host ~ ]# > /etc/krb5.conf
```

#### run authconfig in text mode:

```bash
[ec2-user@host ~ ]# authconfig-tui

On the "authentication Configuration" screen, under Authentication, select Use Kerberos to enable Kerberos authorisation
In the "LDAP Setting" screen, do not change anything
in the "Kerberos settings" screen specify the following:

Realm: RHCE.LOCAL
KDC: ipa.rhce.local
Admin Server: ipa.rhce.local
```

#### Optain a Kerberos ticket for the Kerberos alice user
```bash
[ec2-user@host ~ ]# kinit alice
```

#### verify the ticket:
```bash
[ec2-user@host ~ ]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: alice@RHCE.LOCAL

Valid starting Expires Service principal
07/05/20 11:21:27 08/05/20 11:21:25 krbtgt/RHCE.LOCAL@RHCE.LOCAL
```



## ********* REFERNECES *************

```bash
[ec2-user@host ~ ]# cat /etc/krb5.conf

[libdefaults]
 default_realm = RHCE.LOCAL
 dns_lookup_realm = false
 dns_lookup_kdc = false
[realms]
 RHCE.LOCAL = {
  kdc = ipa.rhce.local
  admin_server = ipa.rhce.local
 }

[domain_realm]
 rhce.local = RHCE.LOCAL
  .rhce.local = RHCE.LOCAL
```

```bash
[ec2-user@host ~ ]# cat /etc/sssd/sssd.conf

[domain/defaults]
autofs_provider = ldap
cache_credentials = True
krb5_realm = RHCE.LOCAL
ldap_search_base = dc=rhce,dc=local
id_provider = ldap
auth_provider = krb5
chpass_provider = krb5
ldap_uri = ldap://ipa.rhce.local/
ldap_id_use_start_tls = True
ldap_tls_cacertdir = /etc/openldap/cacerts
ldap_tls_reqcert = never
krb5_server = ipa.rhce.local
krb5_store_password_if_offline = True
krb5_kpasswd = ipa.rhce.local

[sssd]
services = nss, pam, autofs
config_file_version = 2

domains = default
[...]
```


#### Test Kerberos Configuration
```bash
[ec2-user@host ~ ]# su - alice
su: warning: cannog change directory to /home/alice: No such file or directory
$ hostname
srv2.rhce.local
$ knit
Password for alice@RHCE.LOCAL:

$ klist
Ticket cache: FILE:/tmp/krb5cc_121900005
Default principal: alice@RHCE.LOCAL

Valid starting Experies Service principle
07/05/20 12:04:44 08/05/2012:04:42 krbtgt/RHCE.LOCAL@LOCAL
```

#### Now we can reconnect with out giving any passwords

```bash
$ ssh ipa.rhce.local
Could not create directory '/home/alice/.ssh'
[...]
Could not chdir to home directory /home/alice: No such file or directory
$ hostname
ipa.rhce.local
```
