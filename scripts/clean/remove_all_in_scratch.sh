#!/bin/bash

for i in $(seq 0 59)
do
    echo -ne "\033[31mclean up chapo$i......\033[0m"
    ssh chapo$i "rm -rf /scratch/*"
    [ $? -eq 0 ] && echo -e "\033[31mdone!\033[0m"
done
