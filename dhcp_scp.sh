#!/bin/bash

# Variables
dhcp="/opt/dsi/dhcp/bajadas"

#sudo scp -i /home/dhcp-copy/.ssh/id_dsa dhcp-copy@$1:/etc/dhcp/dhcpd.conf $dhcp/$1
sudo scp -i /home/dhcp-copy/.ssh/id_dsa dhcp-copy@dhcp1.infra.arba.gov.ar:/etc/dhcp/dhcpd.conf $dhcp/$1
