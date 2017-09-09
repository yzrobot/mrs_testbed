#!/bin/bash

# Copyright (C) 2014 Zhi Yan

if [ "$#" -ne 1 ]
then
  echo "Usage : $0 <scenario.blend>"
  exit 1
fi

scenario=$(pwd)/$(echo $1 | cut -f 1 -d '.')
sed -i 's?blender_file?'`echo $scenario`'?' multirobot.py

PARAMS=()
PARAMS+=( --tab -e "bash -c 'roscore;exec bash'" )
PARAMS+=( --tab -e "bash -c 'morse run -g 640x640 `pwd`/multirobot.py;exec bash'" )
gnome-terminal --working-directory=`pwd` "${PARAMS[@]}"

sed -i 's?'`echo $scenario`'?blender_file?' multirobot.py