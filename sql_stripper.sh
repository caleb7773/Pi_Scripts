#!/bin/bash

finish() {
	rm -rf ~/kislog/*
	rm -rf ~/kislog
}
trap finish EXIT

cd ~
rm -rf /tmp/*
mkdir kislog
cd kislog
clear
sudo ls
clear
ssh pi1 'sudo reboot' & ssh pi2 'sudo reboot' & ssh pi3 'sudo reboot' & ssh pi4 'sudo reboot'
sleep 10s
sudo kismet & /usr/lib/firefox/firefox
sudo killall kismet
sleep 4s
clear

#ls ./*.kismet 
#echo ""
#read -p "What Kismet File: " filename
filename=$(ls)
sqlite3 $filename <<EOC
.headers on
.mode csv
.output $filename.csv
SELECT devmac, type, device FROM devices;
.quit
EOC

newfile=$(echo ${filename}.csv)

seenby='kismet.common.seenby.uuid'

grep 'Wi-Fi Client' $newfile | grep -v Neutral | grep -o -n $seenby | cut -d ':' -f 1 | uniq -c > /tmp/output
grep 'Wi-Fi Bridged' $newfile | grep -v Neutral | grep -o -n  $seenby | cut -d ':' -f 1 | uniq -c >> /tmp/output

grep 'Wi-Fi Client' $newfile | grep $seenby > /tmp/outputfull
grep 'Wi-Fi Bridged' $newfile | grep $seenby >> /tmp/outputfull

cat /tmp/output | cut -d ' ' -f 7 > /tmp/output2

rm -rf /tmp/interesting_devices

filename='/tmp/output2'
n=1
while read line; do
if [[ $line == 3 ]];
then
 echo $n >> /tmp/interesting_devices
fi
	n=$((n+1))
done < $filename

rm -rf /tmp/pirate_macs

filename='/tmp/interesting_devices'
n=1
while read line; do
	sed -n "${line}p" /tmp/outputfull >> /tmp/pirate_macs
done < $filename

rm -rf /tmp/got_them

filename='/tmp/pirate_macs'
n=1
while read line; do
	cut -d ',' -f 1 > /tmp/got_them
done < $filename

clear

sort /tmp/got_them > /tmp/got_them.sorted
join -i /tmp/got_them.sorted ~/unifi.dat.devices > /tmp/offenders

cat /tmp/offenders | uniq > /tmp/therealones

quantity=$(cat /tmp/therealones | wc -l)
echo " " 
echo "There are $quantity devices in the JOC!!!"
echo " "
cat /tmp/therealones

cd ~
rm -rf kislog/*
rm -rf kislog
