#!/bin/bash

# Gets temperature of the CPU
# Dependencies: lm_sensors

PREFIX=' '
FIRE=' '

WARNING_LEVEL=80

get_cputemp()
{
	# CPU_T=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon?/temp2_input)
	# CPU_TEMP=$(expr $CPU_T / 1000)

	CPU_TEMP="$(sensors | grep temp1 | awk 'NR==1{gsub("+", " "); gsub("\\..", " "); print $2}')"

	if [ "$CPU_TEMP" -ge $WARNING_LEVEL ]; then
		PREFIX="$FIRE$PREFIX"
	fi

	echo "$PREFIX$CPU_TEMP°C"
}

get_cputemp
