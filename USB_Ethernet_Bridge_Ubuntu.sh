#!/bin/bash


######################################
# Built for Ubuntu 20.04 Rasberry Pi #
######################################


clear
updates=$(sudo ps aux | grep 'unattended-upgrade' | grep -v 'shutdown' | grep -v grep)

while [[ $updates == *"upgrade"* ]];
do
echo "Waiting for updates to finish"
echo "This could take a while...."
echo "Checking again in..."
sleep 1s
echo "     ...4..."
sleep 1s
echo "      ..3.."
sleep 1s
echo "       .2."
sleep 1s
echo "        1"
sleep 1s
clear
updates=$(sudo ps aux | grep 'unattended-upgrade' | grep -v 'shutdown' | grep -v grep)
done



###################################
#Installing necessary dependencies#
###################################
sudo apt-get install isc-dhcp-server -y


#######################
#Edit DHCP Server Info#
#######################
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

#####################################
#Changes netplan interface settings #
#####################################
sudo rm -rf /etc/netplan/*


sudo tee -a /etc/netplan/01-netusb.yaml <<EOF
network:
    ethernets:
        usb0:
            dhcp4: yes
    version: 2
EOF


sudo tee -a /etc/netplan/02-neteth.yaml <<EOF
network:
    ethernets:
        eth0:
            dhcp4: no
            addresses:
                    - 192.168.1.1/24
            nameservers:
                    addresses: [8.8.8.8, 1.1.1.1]
    version: 2
EOF

sudo netplan apply





sudo reboot
