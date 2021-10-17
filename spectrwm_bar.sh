#!/bin/bash

##ram
mem(){
	ramusage=$(free | awk '/Mem/{printf("RAM Usage: %.0f\n"), $3/$2*100}'| awk '{print $3}')
	echo -e "MEM: $ramusage%"
}

cpu() {
	read cpu a b c previdle rest < /proc/stat
	prevtotal=$((a+b+c+previdle))
	sleep 0.5
	read cpu a b c idle rest < /proc/stat
	total=$((a+b+c+idle))
	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	echo "CPU: $cpu%"
}


SLEEP_SEC=10
while :; do
	echo "$(mem) | $(cpu)"
	sleep SLEEP_SEC
done
