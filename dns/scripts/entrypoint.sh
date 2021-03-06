#!/bin/bash
# 0 set env
POD_IP=${POD_IP:-"127.0.0.1"}
TMP=/var/named/named.localhost
URL=gmt.me
NETWORK=192.168.100
EDGENODE=192.168.100.166
ID=${EDGENODE##*.}
TEMP=/tmp/ip.tmp
[ -f ${TEMP} ] || touch $TEMP
echo ${NETWORK} | tr "." "\n" > ${TEMP}
REV=$(tac ${TEMP})
REV=$(echo -n $REV | tr " " ".")
# 1 /etc/named.conf
FILE=/etc/named.conf
cat > $FILE <<EOF
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrator's Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
	listen-on port 53 { any; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	/* 
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable 
	   recursion. 
	 - If your recursive DNS server has a public IP address, you MUST enable access 
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification 
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface 
	*/
	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF
# 2 /etc/named.rfc1912.zones
FILE=/etc/named.rfc1912.zones
if ! cat $FILE | grep "$URL" >/dev/null 2>&1; then
  cat >> $FILE <<EOF
zone "${URL}" IN {
type master;
file "${URL}.zone";
allow-update { none; };
};
 
zone "${REV}.in-addr.arpa" IN {
type master;
file "${NETWORK}.arpa";
allow-update { none; };
};
EOF
fi
# 3 /var/named/test.com.zone
FILE=/var/named/${URL}.zone
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
	A 	127.0.0.1	
	AAAA	::1
ns  IN  A   ${POD_IP}
dash   IN  A   ${EDGENODE}
EOF
# 4 /var/named/192.168.100.arpa 
FILE=/var/named/${NETWORK}.arpa
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
	A 	127.0.0.1	
	AAAA	::1
	PTR localhost.
ns  IN  A   ${POD_IP} 
${ID} IN  PTR dash.${URL}
EOF
# 
SVC=named
systemctl daemon-reload 
systemctl restart $SVC
