#!/bin/bash

##############################################################################
# Script for multi-robot exploration experiments on CHAPO of Ecole des Mines #
# Zhi Yan, Luc Fabresse, Jannik Laval, and Noury Bouraqadi                   #
# Copyright 2014 yz@ai.univ-paris8.fr                                        #
##############################################################################

###### Set your name to run start_simulation.sh correctly. ######
# sed -i 's?zhi.yan?'$(echo ${HOME##*/})'?' start_simulation.sh #
###### Create a directory to store job submission results. ######
[ -d ../Qsubresults ] || mkdir -p ../Qsubresults
#################################################################

##################### ADVISE FOR FIRST RUN  #####################
if [ $# -eq 0 ]
then
    echo -e "\033[34mWelcome to use our script for multi-robot exploration experiments!\033[0m"
    echo -e "\033[34mIf this is your first time, I suggest you to run once in debug mode, rather than submit the job to CHAPO immediately.\033[0m"
    echo -ne "\033[33mYou want to run it in debug mode? [y/n]: \033[0m"
    read ANSWER
    case $ANSWER in
	y|Y|yes|YES)
	    $SHELL start_simulation.sh
	    exit 0
	    ;;
    esac
fi
#################################################################

###### EXPERIMENT PARAMETERS PART 1: NEED TO BE SPECIFIED  ######
if [[ $# -ne 3 ]]
then
    echo "Usage:" $0 "[MIN NUMBER OF ROBOTS] [MAX NUMBER OF ROBOTS] [NUMBER OF TRIALS PER TEAM SIZE]"
    exit 0
fi
N_ROBOTS_MIN=$1
N_ROBOTS_MAX=$2
N_TRIALS_PTS=$3
#################################################################

############## EXPERIMENT PARAMETERS PART 2: PRESET #############
N_ROBOTS_PER_NODE=4
N_VM_MEMS=2048
N_VM_CPUS=2
#################################################################

############# EXPERIMENT PARAMETERS PART 2: ADAPTED #############
N_NODES=$[ $N_ROBOTS_MAX / $N_ROBOTS_PER_NODE ]
if [ $[ $N_ROBOTS_MAX % $N_ROBOTS_PER_NODE ] -ne 0 ]
then
    N_NODES=$[ $N_NODES + 1 ]
fi
#################################################################

######################## SUBMIT THE JOB #########################
qsub \
    -N car_mrs_explore \
    -d $PWD \
    -r n \
    -m abe \
    -M ${HOME##*/}@mines-douai.fr \
    -l nodes=$N_NODES:ppn=8 \
    -l walltime=500:00:00 \
    -l pmem=1gb \
    -o $(dirname $(pwd))/Qsubresults \
    -e $(dirname $(pwd))/Qsubresults \
    -j oe \
    -v DEBUG_MODE=false,RESET_VM=true,SIM_ENV_NAME=maze,ODOMETRY_NOISE=true,N_ROBOTS_MIN=$N_ROBOTS_MIN,N_ROBOTS_MAX=$N_ROBOTS_MAX,N_TRIALS_PTS=$N_TRIALS_PTS,N_ROBOTS_PER_NODE=$N_ROBOTS_PER_NODE,N_VM_MEMS=$N_VM_MEMS,N_VM_CPUS=$N_VM_CPUS \
    start_simulation.sh
#################################################################

echo "
##############################################################
##  Your job has been submitted with following parameters:  ##
##                                                          ##
       * N_ROBOTS_MIN      = $N_ROBOTS_MIN
       * N_ROBOTS_MAX      = $N_ROBOTS_MAX
       * N_TRIALS_PTS      = $N_TRIALS_PTS
       * N_ROBOTS_PER_NODE = $N_ROBOTS_PER_NODE
       * N_VM_MEMS         = $N_VM_MEMS
       * N_VM_CPUS         = $N_VM_CPUS
       * N_NODES           = $N_NODES
##                                                          ##
## Zhi Yan, Luc Fabresse, Jannik Laval, and Noury Bouraqadi ##
##                      Copyright 2014                      ##
##############################################################
"
