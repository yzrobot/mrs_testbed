#!/bin/bash

### Copyright (C) 2014 Zhi Yan

LOG_FILE_NAME="team$1_test$2_robot$3.csv"
LOG_FILE_PATH="/media/sf_scratch/$4/log"
LOG_FREQUENCY=5 # record once every LOG_FREQUENCY seconds

mkdir -p $LOG_FILE_PATH
echo "cpu(used/total),ram(used/total),net_in(Kbytes/s),net_out(Kbytes/s)" > $LOG_FILE_PATH/$LOG_FILE_NAME

cpu_usage=0
memory_usage=0
net_in=0
net_out=0

record_loop() {
    while [ 1 ]
    do
	cpu_usage=$((100-$(vmstat | tail -1 | awk '{print $15}')))
	memory_usage=$(free -m | grep Mem | awk '{print $3/$2 * 100}')
	net_in=$(nicstat | grep eth0 | awk '{print $3}')
	net_out=$(nicstat | grep eth0 | awk '{print $4}')
	echo "$cpu_usage,$memory_usage,$net_in,$net_out" >> $LOG_FILE_PATH/$LOG_FILE_NAME
	sleep $LOG_FREQUENCY
    done
}

record_loop & # we have to put it to background to not block roslaunch