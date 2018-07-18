#!/bin/bash
set -ex
# 0 set env
TMP=/var/named/named.localhost
# 1 /etc/named.conf
FILE=/etc/named.conf
sed -i s?"listen-on port 53 { 127.0.0.1; };"?"listen-on port 53 { any; };"?g $FILE
sed -i s?"allow-query     { localhost; };"?"allow-query     { any; };"?g $FILE
# 2 /etc/named.rfc1912.zones
FILE=/etc/named.rfc1912.zones
cat >> $FILE <<"EOF"
zone "test.com" IN {
        type master;
        file "test.com.zone";
        allow-update { none; };
};
 
zone "100.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.100.arpa";
        allow-update { none; };
};
EOF
# 3 /var/named/test.com.zone
FILE=/var/named/test.com.zone
cp -p $TMP $FILE
cat > $FILE <<EOF
\$TTL 1D
@	IN SOA	@ rname.invalid. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	@
	A 	192.168.100.166	
	AAAA	::1
    IN  A   $POD_IP
node1   IN  A   192.168.100.162
node2   IN  A   192.168.100.163
node3   IN  A   192.168.100.164
EOF
# 4 /var/named/192.168.100.arpa 
FILE=/var/named/192.168.100.arpa
cp -p $TMP $FILE
cat > $FILE <<EOF
\$TTL 1D
@	IN SOA	@ rname.invalid. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	@
	A 	192.168.100.166	
	AAAA	::1
    PTR localhost.
ns  IN  A   $POD_IP 
100 IN  PTR ns.test.com
161 IN  PTR node1.test.com
162 IN  PTR node2.test.com
163 IN  PTR node3.test.com
EOF
# 
SVC=named
systemctl daemon-reload 
systemctl restart $SVC
