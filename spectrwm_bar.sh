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

wifi(){
	echo -e "WiFi: $(nmcli dev status | grep -w 'connected'|awk '{ s = ""; for (i = 4; i <= NF; i++) s = s $i " "; print s }')"
}

batt(){
	echo -e "$(acpi | awk '{print $5}')"
	sleep 2
}

temp(){
   echo -e TMP:`head -n 1 /sys/class/thermal/thermal_zone0/temp | xargs -I{} awk "BEGIN {printf \"%.0f\n\", {}/1000}"`c
   sleep 2
}


SLEEP_SEC=10
while :; do
    echo "$(mem) | $(cpu) | $(wifi) | $(temp) | $(batt)"
	sleep SLEEP_SEC
done
