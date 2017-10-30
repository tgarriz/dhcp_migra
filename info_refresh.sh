#!/bin/bash


let Index=0;
let Ip,Mac;


cat $1/dhcp.info* > /tmp/ip_mac
cat /tmp/ip_mac | cut -f 1,2 -d ',' > /tmp/ip_mac_2

sort -u /tmp/ip_mac_2 > /tmp/lista_ips
sed -i "s/INSERT INTO pl_net_negociaron_dhcp VALUES (//g" /tmp/lista_ips
sed "s/'//g" /tmp/lista_ips | sed "s/,/;/g" | sort -u -t . -k 3,3n -k 4,4 | grep ^10.  > /tmp/lista_ips_2.conf
#Armo script sql
cat /tmp/lista_ips_2.conf | tr [:upper:] [:lower:] | sort | sed 's/;<br>//g' | awk -F";" '{ print "INSERT INTO  `ip_negociadas` (  `ip` ,  `mac` ) VALUES (\""$1"\",   \""$2"\");" }' > info.sql

# Clean table dhcp.
mysql -u root --password=eflhr.14 -D dhcp_migra -e 'truncate table ip_negociadas;';
# Upload dhcp.sql
mysql -u root --password=eflhr.14 dhcp_migra < info.sql;
