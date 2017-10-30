#!/bin/bash
data_info=./data
data_dhcp=.
#router=$1

#if [ -z router ] 
#then 
#	echo  "es nulo";
#	exit 1;
#fi

#echo "router $1";
let Index=0;
let Ip,Mac;

./dhcp_refresh.sh $data_dhcp ;
echo "termina dhcp_refresh";
./info_refresh.sh $data_info ;

mysql -u root --password=eflhr.14 -D dhcp_migra -e 'select ip, mac from dhcp_conf where concat(ip,mac) not in (select concat(ip,mac) from ip_negociadas);' | sed 1d | sort -u -t . -k 3,3n -k 4,4n > ips_no_negociadas.txt;

mysql -u root --password=eflhr.14 -D dhcp_migra -e 'select ipn.ip, ipn.mac from ip_negociadas ipn inner join dhcp_conf dh on ipn.ip=dh.ip and ipn.mac=dh.mac;' | sed 1d | sort -u -t . -k 3,3n -k 4,4n > /tmp/fortinet.tmp;

#Encabezado Fortinet
echo "config system dhcp server" > /tmp/fortinet.txt;
echo "edit 1" >> /tmp/fortinet.txt;
echo "config reserved-address" >> /tmp/fortinet.txt;
cat /tmp/fortinet.tmp | while read line
do 

#   echo "indes: ${Index}";
#   echo "ip: ${Ip}";
#   echo "Mac:${Mac}";
   Ip=$(echo $line | cut -f 1 -d ' ');
   LastByte=$(echo $Ip | cut -f 4 -d '.');
   Mac=$(echo $line | cut -f 2 -d ' ');
   let Index=$((Index+1));

   #echo "edit ${Index}" >> /tmp/fortinet.txt
   echo "edit $LastByte" >> /tmp/fortinet.txt
   echo "	set ip ${Ip}" >> /tmp/fortinet.txt; 
   echo "	set mac	${Mac}" >> /tmp/fortinet.txt; 	
   echo "	next" >> /tmp/fortinet.txt;

   # do something with $line here;
done;

   `head -n -1 /tmp/fortinet.txt > fortinet.txt`;
    echo "	end" >> fortinet.txt;

   unset ip;
   unset Mac;
