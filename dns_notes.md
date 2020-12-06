*** LINK *** https://opensource.com/article/17/4/build-your-own-name-server

Installing and configuring internal DNS server on ec2-instances


install the dns server
```bash
[ec2-user@host ~ ]# yum install -y bind
```

 get loopback and local interfaces ip's

```bash
[ec2-user@host ~ ]# ip adder show | grep inet
```
 should display <INET_IP_ADDRESS>


change this line from /etc/named.conf

FROM:
```bash
listen-on port 53 { 127.0.0.1 };
```
TO:
```bash
listen-on port 53 { 127.0.0.1; <INET_IP_ADDRESS> };
```

 start the named daemon
```bash
[ec2-user@host ~]# service named start
```

 test to resolve hostname
```bash
[ec2-user@host ~ ]# ping -c 1 `hostname`
```
###### if above returns "ping: unknown host <hostname>" then edit /etc/hosts file
```bash
[ec2-user@host ~ ]# cat /etc/hosts
127.0.0.1 rhel7 localhost localhost.localdomain localhost4 localhost4.localdomain4
<INET_IP_ADDRESS> <YOUR_HOSTNAME>
::1             localhost localhost.localdomain localhost6 localhost6.localdomain6
```
 now try ping again
 after ping works check port 53 is open

```bash
[ec2-user@host ~ ]# netstat -ant | grep -w 53
tcp    0    0 <INET_IP_ADDRESS>:53    0.0.0.0:*  LISTEN
tcp    0    0 127.0.0.0:53            0.0.0.0:*  LISTEN
tcp6   0    0 ::1:53                  :::*       LISTEN
```

 we can see that the dns server
 is listening on <INET_IP_ADDRESS>
 and loopback interface



 firewall needs to be open for dns queries
```bash
[ec2-user@host ~ ]# firewall-cmd --zone=public --add-port=53/tcp --permanent
success
[ec2-user@host ~ ]# firewall-cmd --zone=public --add-port=53/udp --permanent
success
[ec2-user@host ~ ]# firewall-cmd --reload
```

 test access to port 53 from other hosts with 'nmap'
```bash
[ec2-user@host ~ ]# nmap -p 53 <INET_IP_ADDRESS>      # tcp
[ec2-user@host ~ ]# nmap -sU -p 53 <INET_IP_ADDRESS>  # upd
```


 zone file configuration
```bash
[ec2-user@host ~ ]# mkdir -p /etc/bind/zones/master
[ec2-user@host ~ ]# vi /etc/bind/zonez/master/nibble.config.org
;
; Bind data file for nibble.config.org
;
$TTL 3h
@ IN SOA nibble.config.org admin.nibble.config.org (
1 ; Serial
3h ; Refresh after 1 hour
1h ; Retry after 1 hour
1w ; Expire after 1 week
1h ) ; Negative caching TTL of 1 day
;
@ IN NS ns1.rhel7.local.
@ IN NS ns2.rhel7.local.

nibble.config.org. IN A 1.1.1.1
www IN A 1.1.1.1
```

 Add correct name server records to your FQDN
 Now incude the new zone file to the named config file:
```bash
[ec2-user@host ~ ]# vi /etc/named.rfc1912.zones
zone "nibble.config.org {
type master;
file "/etc/bind/zones/master/nibble.config.org";
};
```

 Restart the dns server
```bash
[ec2-user@host ~ ]# service named restart
Redirecting to /bin/systemctl restart named.service
```

 If no errors and named daemon started correctly and
 change one line in named configuration file to
 allow queries from EXTERNAL RESOURCES
```bash
[ec2-user@host ~ ]# vi /etc/named.conf
FROM:
allow-query { localhost; };
TO:
allow-query { any; };
```

 Restart named
```bash
[ec2-user@host ~ ]# service named restart
Redirecting to /bin/systemctl restart named.service
```

 Make sure the named service starts on startup
```bash
[ec2-user@host ~ ]# systemctl enable named
ln -s '/usr/lib/systemd/system/named.service' '/etc/systemd/system/multi-user.target.wants/named.service'
```



 Test dns server to resolve nibble.config.org
 and test a query for nibble.config.org
 from external hoss

```bash
[ec2-user@host ~ ]# dig @<INET_IP_ADDRESS> www.nibble.config.org
```





****NOTES
RHEL ships BIND with the most secure SELinux policy that will not permit normal BIND operation.
By default SELinux dose not allow named to write any master zone database files.
Only root can create files in $ROOTDIR/var/named zone database where $ROOTDIR is set in /etc/sysconfig/named.

The "named" group must be granted read priveleges to these files.




