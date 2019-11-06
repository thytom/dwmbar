#!/bin/bash

# Prints out the volume percentage

# Dependencies: bc

VOLUME_WIDTH=9
VOLUME_SLIDER='⬤'
VOLUME_RAIL='◯'
VOLUME_MUTED='muted'

PREFIX=''

# If volume is >100
ALERT='!!!'

get_volume(){
        active_sink=$(pacmd list-sinks | awk '/* index:/{print $3}')
        curStatus=$(pacmd list-sinks | grep -A 15 "index: $active_sink$" | awk '/muted/{ print $2}')
        volume=$(pacmd list-sinks | grep -A 15 "index: $active_sink$" | grep 'volume:' | grep -E -v 'base volume:' | awk -F : '{print $3}' | grep -o -P '.{0,3}%'| sed s/.$// | tr -d ' ')
		slider_position=$(python -c "print(($volume / 100) * $VOLUME_WIDTH)")

        if [ "${curStatus}" = 'yes' ]
        then
            echo "$VOLUME_MUTED"
			exit 0
        else
			for i in $(seq 1 $VOLUME_WIDTH); do
				[[ $i = $slider_position ]] && BAR=$BAR$VOLUME_SLIDER
				[[ $i < $slider_position ]] && BAR=$BAR$VOLUME_SLIDER
				[[ $i > $slider_position ]] && BAR=$BAR$VOLUME_RAIL
			done
        fi

		[[ $volume -gt 100 ]] && PREFIX=$PREFIX$ALERT

		echo "$PREFIX$BAR"
}

get_volume
