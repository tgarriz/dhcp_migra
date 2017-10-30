#!/bin/bash


rm /tmp/*.conf;
cat $1/dhcpd.conf | grep -v ^# > /tmp/dhcp_tmp.conf;

unset mac;
unset ip;

#sudo awk '/hardware ethernet/ { var=$NF }; /fixed-address/ { print var, $NF }' /tmp/dhcp_tmp.conf > /tmp/dhcp_lista.conf

#Recorro y junto las ip
cat /tmp/dhcp_tmp.conf | while read line
    do
    ip=$(echo $line  |  grep "fixed-address"  | cut -d " " -f 2 | sed 's/.$//g' | sed 's/ //g');
    if [ ! -z $ip  ]; then
	echo "${ip}" >> /tmp/dhcp_ip.conf;
    fi;
    unset ip;
done;

#Recorro y junto las macs
 cat /tmp/dhcp_tmp.conf | while read line
 do
    mac=$(echo $line | grep "hardware ethernet" | cut -d " " -f 3 | sed 's/.$//g');
    if [ ! -z $mac  ]; then
	echo "${mac}" >> /tmp/dhcp_mac.conf;
    fi;
    unset mac;
 done;

#Armo la lista ip,mac
aux=$(cat /tmp/dhcp_mac.conf | wc -l);
for ((i=1;i<=$aux;i++))
do
	ip=$(awk NR==$i /tmp/dhcp_ip.conf);
	mac=$(awk NR==$i /tmp/dhcp_mac.conf);
	echo "${mac}; ${ip}" >> /tmp/dhcp_lista2.conf;
done;

cat /tmp/dhcp_lista2.conf | tr [:upper:] [:lower:] | sort | sed 's/;<br>//g' | awk -F";" '{ print "INSERT INTO  `dhcp_conf` (  `id` ,  `mac` ,  `ip` ) VALUES (NULL ,  \""$1"\",   \""$2"\");" }' | sed 's/" /"/g' > dhcp.sql

unset mac;
unset ip;
# Clean table dhcp.
mysql -u root --password=eflhr.14 -D dhcp_migra -e 'truncate table dhcp_conf;';
# Upload dhcp.sql
mysql -u root --password=eflhr.14 dhcp_migra < dhcp.sql;
