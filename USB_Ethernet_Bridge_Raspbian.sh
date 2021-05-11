#!/bin/bash

######################
# Built for RASPBIAN #
######################

# Prior to running this script run the following on the RASPBIAN IP
#
# sudo apt update -y
# sudo apt upgrade -y 
# sudo apt install git -y
#

##########################
#INSTALLING DEPENDENCIES #
##########################
sudo apt-get install vim -y
sudo apt-get install isc-dhcp-server -y


#########################
#SETTING UP DHCP SERVER #
#########################

sudo tee -a /etc/dhcp/dhcpd.conf <<EOF
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
  option domain-name-servers 1.1.1.1;
}
EOF

sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/g' /etc/default/isc-dhcp-server

#####################
#IPTABLES BUILD OUT #
#####################
sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE



#############################################################################
#Installs iptables-persistent without screen prompt for saving IPv4 and IPv6#
#############################################################################
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y



#####################
#Enable IPv4 Routing#
#####################
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sudo sysctl -p

#############################
#Changes interface settings #
#############################

sudo tee -a /etc/dhcpcd.conf <<EOF
interface eth0
static ip_address=192.168.1.1/24
static domain_name_servers=1.1.1.1 8.8.8.8
EOF

##############################
#DISABLE BT AND WIFI ON BOOT #
##############################

sudo tee -a /boot/config.txt <<EOF
dtoverlay=disable-wifi
dtoverlay=disable-bt
EOF

sudo reboot
