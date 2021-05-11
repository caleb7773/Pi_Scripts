#!/bin/bash


#############################################
# Add the following line to sudo crontab -e #
# @reboot bash /home/pi/lights.sh           #
#                                           #
# Store this file in /home/pi/lights.sh     #
# sudo chmod +x /home/pi/lights.sh          #
#                                           #
# "sudo raspi-config" to set keyboard to US #
#############################################

sleep 60s


GPIO() {
	echo "9" > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio9/direction
	echo "11" > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio11/direction
}
blue_on() {
	echo "1" > /sys/class/gpio/gpio9/value
}
blue_off() {
	echo "0" > /sys/class/gpio/gpio9/value
}
green_on() {
	echo "1" > /sys/class/gpio/gpio11/value
}
green_off() {
	echo "0" > /sys/class/gpio/gpio11/value
}
GPIO

dhcpcheck() {
dhcpstatus=$(sudo service isc-dhcp-server status | grep failed )

while [[ $dhcpstatus == *"failed"* ]];
do
	sudo service isc-dhcp-server restart
	green_on
	sleep 1s
	green_off
	dhcpstatus=$(sudo service isc-dhcp-server status | grep failed )

done

green_on
}

dhcpcheck

internetcheck() {

internet=$(sudo ping 1.1.1.1 -w1 -c1)

if [[ $internet == *"icmp"* ]];
then
blue_on
else
blue_on
sleep 1s
blue_off
sleep 1s
internetcheck
fi

}
internetcheck

while [[ 1 != 2 ]];
do
	sleep 10s
	internetcheck
	dhcpcheck
done
