#!/bin/bash

# Prints the fan RPM
# Depends on lm_sensors

PREFIX=' '

get_fan_speed()
{
    echo "$PREFIX$(sensors | grep fan1 | awk 'NR==1{print $2}') RPM"
}

get_fan_speed
