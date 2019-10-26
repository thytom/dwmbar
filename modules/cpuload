#!/bin/bash

# Prints out the CPU load percentage

PREFIX=' '

get_load()
{
  # Get the first line with aggregate of all CPUs
  cpu_last=($(head -n1 /proc/stat))
  cpu_last_sum="${cpu_last[@]:1}"
  cpu_last_sum=$((${cpu_last_sum// /+}))

  sleep 0.05

  cpu_now=($(head -n1 /proc/stat))
  cpu_sum="${cpu_now[@]:1}"
  cpu_sum=$((${cpu_sum// /+}))

  cpu_delta=$((cpu_sum - cpu_last_sum))
  cpu_idle=$((cpu_now[4]- cpu_last[4]))
  cpu_used=$((cpu_delta - cpu_idle))
  cpu_usage=$((100 * cpu_used / cpu_delta))

  # Keep this as last for our next read
  cpu_last=("${cpu_now[@]}")
  cpu_last_sum=$cpu_sum

  echo "$PREFIX $cpu_usage%"
}

get_load
