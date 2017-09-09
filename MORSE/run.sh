#!/bin/bash

# Copyright (C) 2014 Zhi Yan



sed -i 's?blender_file?'`pwd`'/maze?' maze.py

PARAMS=()
PARAMS+=( --tab -e "bash -c 'roscore;exec bash'" )
PARAMS+=( --tab -e "bash -c 'morse run -g 640x640 maze.py;exec bash'" )
gnome-terminal --working-directory=`pwd` "${PARAMS[@]}"
