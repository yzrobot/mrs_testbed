#!/bin/bash

# Copyright (C) 2014 Zhi Yan

if [ "$#" -ne 1 ]
then
  echo "Usage : $0 <scenario.blend>"
  exit 1
fi

scenario=$(pwd)/$(echo $1 | cut -f 1 -d '.')
sed -i 's?blender_file?'`echo $scenario`'?' singlerobot.py

PARAMS=()
PARAMS+=( --tab -e "bash -c 'roscore;exec bash'" )
PARAMS+=( --tab -e "bash -c 'morse run -g 768x768 `pwd`/singlerobot.py;exec bash'" )
PARAMS+=( --tab -e "bash -c 'sleep 3;roslaunch mapping.launch;exec bash'" )
gnome-terminal --working-directory=`pwd` "${PARAMS[@]}"

sed -i 's?'`echo $scenario`'?blender_file?' singlerobot.py