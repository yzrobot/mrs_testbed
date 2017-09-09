#!/bin/bash

############################ JOB SUBMISSION OPTIONS ############################
############################### !!! WARNING !!! ################################
############ !!! Do not edit this part to change PBS parameters !!! ############
##### You should edit the parameters for command "qsub" in "submit_job.sh" #####
#                                                                              #
# --- specifying a job name ---                                                #
# #PBS -N car_mrs_explore                                                      #
#                                                                              #
# --- working directory ---                                                    #
# #PBS -d /home/zhi.yan/Simulation/Scripts                                     #
#                                                                              #
# --- marking a job as rerunnable or not ---                                   #
# #PBS -r n                                                                    #
#                                                                              #
# --- specifying e-mail notification ---                                       #
# --- (a)boreted (b)egins (e)nds ---                                           #
# #PBS -m abe                                                                  #
#                                                                              #
# --- setting e-mail recipient list ---                                        #
# #PBS -M zhi.yan@mines-douai.fr                                               #
#                                                                              #
# --- resource request, can be overridden by command line ---                  #
# --- 8 (p)rocessors (p)er (n)ode ---                                          #
# #PBS -l nodes=4:ppn=8                                                        #
# --- 24 hours maximum for the total job ---                                   #
# #PBS -l walltime=24:00:00                                                    #
# --- 1gb RAM per processor ---                                                #
# #PBS -l pmem=1gb                                                             #
#                                                                              #
# --- redirecting (o)utput and (e)rror files ---                               #
# #PBS -o /home/zhi.yan/Simulation/Qsubresults                                 #
# #PBS -e /home/zhi.yan/Simulation/Qsubresults                                 #
################################################################################

################################### DOCUMENTS ##################################
# http://wiki.ibest.uidaho.edu/index.php/Tutorial:_Submitting_a_job_using_qsub #
# https://www.virtualbox.org/manual/ch08.html                                  #
# https://github.com/andrewpile/ssh-copy-id/blob/master/ssh-copy-id            #
################################################################################

########################## LAUNCH ME BY COMMAND LINE ###########################
# qsub -l nodes=4:ppn=8:pmem=1gb \                                             #
# -v N_ROBOTS_MIN=1,N_ROBOTS_MAX=16,N_TRIALS_PTS=5,N_ROBOTS_PER_NODE=4, \      #
# N_VM_MEMS=2048,N_VM_CPUS=2 start_simulation.sh                               #
################################################################################

echo "
##############################################################
#        Script for Multi-robot Exploration Simulation       #
#  Zhi Yan, Luc Fabresse, Jannik Laval, and Noury Bouraqadi  #
#                       Copyright 2014                       #
##############################################################
"

####################### DEBUG SETTINGS #######################
[ -z $DEBUG_MODE ] && DEBUG_MODE="true" # Debug mode
if [ $DEBUG_MODE == "true" ]
then
    RESET_VM="false"       # Re-copy and re-clone all virtual machines (need more time!)
    SIM_ENV_NAME="maze"    # morse simulation environment file names (blend, pgm, yaml, sh)
    ODOMETRY_NOISE="false" # set odometry noise or perfect in morse description file
    N_ROBOTS_MIN=4         # Minimum number of robots
    N_ROBOTS_MAX=4         # Maximum number of robots
    N_TRIALS_PTS=1         # Number of trials per team size
    N_ROBOTS_PER_NODE=2    # Number of robots per CHAPO node
    N_VM_MEMS=2048         # Memory size (MB) for 1 virtual machine
    N_VM_CPUS=2            # Number of CPUs for 1 virtual machine
    
    echo "
##############################################################
  Script running in *DEBUG* mode with following parameters:
          * RESET_VM          = $RESET_VM
          * SIM_ENV_NAME      = $SIM_ENV_NAME
          * ODOMETRY_NOISE    = $ODOMETRY_NOISE
          * N_ROBOTS_MIN      = $N_ROBOTS_MIN
          * N_ROBOTS_MAX      = $N_ROBOTS_MAX
          * N_TRIALS_PTS      = $N_TRIALS_PTS 
          * N_ROBOTS_PER_NODE = $N_ROBOTS_PER_NODE
          * N_VM_MEMS         = $N_VM_MEMS
          * N_VM_CPUS         = $N_VM_CPUS
##############################################################
"
fi
##############################################################

######################### ERROR CODES ########################
ERROR_FILE_NOT_FOUND=1
ERROR_DIRECTORY_NOT_FOUND=2
ERROR_AUTO_SSH_COPY_ID=3
ERROR_AUTO_SSH=4
ERROR_SSH_INTERACTIVE_MODE=5
ERROR_VM_SETUP_FAILS=6
ERROR_RESOURCE_CONFLICT=7
ERROR_MAX_FAILED_ROBOTS=8
##############################################################

###################### SCRIPT VARIABLES ######################
ROBOT_DEPLOYMENT_PATH="/scratch/${HOME##*/}" # where we deploy robot(s)
ROBOT_PROTOTYPE_PATH="/home/${HOME##*/}/lustre/robot_prototype" # robot prototype directory (VM) on CHAPO
ROBOT_PROTOTYPE_IP="10.3.12.99"  # IP of robot prototype VM
ROBOT_PROTOTYPE_USER="viki"      # default username of robot prototype VM
ROBOT_PROTOTYPE_PASS="viki"      # default password of robot prototype VM
ROBOT_INIT_POSE_X=0              # initial posiiton x for robot(s)
ROBOT_INIT_POSE_Y=0              # initial posiiton y for robot(s)
ROBOT_INIT_POSE_Z=0              # initial posiiton z for robot(s)

MORSE_USER="car"                 # ssh username for HP-Z420 Workstation
MORSE_HOST="10.1.10.84"          # IP of HP-Z420 Workstation
MORSE_PASS="car"                 # ssh password for HP-Z420 Workstation
MORSE_FILE_PATH="/home/car/test" # where we store files to launch morse (absolute path!)

MONITOR_PKG_NAME="zsupervision"           # monitor name (ROS package)
MONITOR_LOG_PATH="/home/car/test/results" # location for storing experimental results
MONITOR_LISTEN_PORT="1234"                # exploration end signal listening port
##############################################################

###################### SHELL FUNCTIONS #######################
auto_ssh() {
    expect -c "set timeout -1;
               spawn ssh -o StrictHostKeyChecking=no $2 ${@:3};
               expect {
                       *password* {
                                   send -- $1\r;
                                   expect {
                                           *denied* {exit 3;}
                                           eof
                                          }
                                  }
                       *route* {exit 2;}
                       eof {exit 1;}
                      }"
    return $?
}

#auto_scp() {
#    expect -c "set timeout -1;
#               spawn scp -o StrictHostKeyChecking=no ${@:2};
#               expect {
#                       *password* {
#                                   send -- $1\r;
#                                   expect { 
#                                           *denied* {exit 2;}
#                                           eof
#                                          }
#                                  }
#                       eof {exit 1;}
#                      }"
#    return $?
#}

auto_ssh_copy_id() {
    expect -c "set timeout -1;
               spawn ssh-copy-id $2;
               expect {
                       *ERROR* {exit 1;}
                       *Usage* {exit 1;}
                       *(yes/no)* {send -- yes\r;exp_continue;}
                       *password:* {send -- $1\r;exp_continue;}
                       eof {exit 0;}
                      }"
}

set_robot_init_pose() {
    ROBOT_INIT_POSE_X=-38.0
    ROBOT_INIT_POSE_Y=$(echo "38.0 - 2.0 * $1" | bc)
    ROBOT_INIT_POSE_Z=0.0
}
##############################################################

############## EXPERIMENT ENVIRONMENT TESTINGS ###############
### TEST 0 ###
[ -d morse ] || mkdir -p morse
[ -d robot ] || mkdir -p robot
[ -d log ] || mkdir -p log
### TEST 1 ###
echo -n "===> Checking file \"$SIM_ENV_NAME.blend\" ...... "
if [ ! -f $PWD/morse/$SIM_ENV_NAME.blend ]
then
    echo "****************************************************
ERROR: $SIM_ENV_NAME.blend not found.
SOLUTION: put \"$SIM_ENV_NAME.blend\" into \"$PWD/morse\".
****************************************************"
    exit $ERROR_FILE_NOT_FOUND
fi
echo "found!"
### TEST 2 ###
echo -n "===> Checking file \"id_rsa.pub\" ...... "
if [ ! -f $HOME/.ssh/id_rsa.pub ]
then
    echo "****************************************************
ERROR: $HOME/.ssh/id_rsa.pub not found.
SOLUTION: execute \"ssh-keygen\" command first.
****************************************************"
    exit $ERROR_FILE_NOT_FOUND
fi
echo "found!"
### TEST 3 ###
auto_ssh $MORSE_PASS $MORSE_USER@$MORSE_HOST :
SSH_ERROR_CODE=$?
if [ $SSH_ERROR_CODE -eq 0 ]
then
    auto_ssh_copy_id $MORSE_PASS "-i $HOME/.ssh/id_rsa.pub $MORSE_USER@$MORSE_HOST"
    if [ $? -eq 1 ]
    then
	exit $ERROR_AUTO_SSH_COPY_ID
    fi
fi
if [ $SSH_ERROR_CODE -gt 1 ]
then
    exit $ERROR_AUTO_SSH
fi
echo "===> SSH authentication is ok!"
### TEST 4 ###
if [ -z "$(ssh $MORSE_USER@$MORSE_HOST 'echo $ROS_HOSTNAME')" ]
then
    echo "****************************************************
ERROR: $0 can not be executed in interactive mode.
SOLUTION: comment out \"[ -z \"\$PS1\" ] && return\" in $MORSE_USER@$MORSE_HOST:~/.bashrc.
****************************************************"
    exit $ERROR_SSH_INTERACTIVE_MODE
fi
echo "===> MORSE host is ready!"
### TEST 5 ###
echo -n "===> Checking directory \"$ROBOT_PROTOTYPE_PATH\" ...... "
if [ ! -d $ROBOT_PROTOTYPE_PATH ]
then
    echo -n "not found. Copy from /lustre/zhi.yan ...... "
    cp -rf /lustre/zhi.yan/robot_prototype/ $ROBOT_PROTOTYPE_PATH
    if [ $? -ne 0 ]
    then
	echo "****************************************************
ERROR: can not get the robot prototype.
SOLUTION: please contact Zhi Yan (yz@ai.univ-paris8.fr).
****************************************************"
	exit $ERROR_DIRECTORY_NOT_FOUND
    else
	echo "done!"
    fi
else
    echo "found!"
fi
### TEST 6 ###
[ -z $PBS_JOBNAME ] && PBS_JOBNAME=$0
if [[ $(qstat | grep -c $PBS_JOBNAME) -gt 1 || $(ssh $MORSE_USER@$MORSE_HOST "ps -ef | grep -c ros") -gt 2 || $(ps -ef | grep -c $0) -gt 3 ]]
then
    echo "****************************************************
ERROR: another experiment in progress.
SOLUTION: please try again later.
****************************************************"
    exit $ERROR_RESOURCE_CONFLICT
fi
##############################################################

#### EXPERIMENT DEPLOYMENT PHASE I: CHAPO NODE ALLOCATION ####
echo "
**** EXPERIMENT DEPLOYMENT PHASE I: CHAPO NODE ALLOCATION ****
"
NODE_ALLOCATION_LIST=()
if [ $DEBUG_MODE == "false" ]
then
    NODES=$(sort -u $PBS_NODEFILE)
    for node_name in $NODES
    do
	NODE_ALLOCATION_LIST+=(${node_name})
    done
else
    NODE_ALLOCATION_LIST+=( "chapo47" "chapo48" )
fi
#echo "NODE_ALLOCATION_LIST = ${NODE_ALLOCATION_LIST[*]}"

ROBOT_IP_LIST=()
for robot_id in $(seq 0 $[ $N_ROBOTS_MAX - 1 ])
do
    ROBOT_IP_LIST+=(${ROBOT_PROTOTYPE_IP/99/$[ 100 + robot_id ]})
    echo "robot$robot_id (${ROBOT_IP_LIST[$robot_id]}) will be deployed on ${NODE_ALLOCATION_LIST[$[ $robot_id / $N_ROBOTS_PER_NODE ]]}."
done
#echo "ROBOT_IP_LIST = ${ROBOT_IP_LIST[*]}"
##############################################################

#### EXPERIMENT DEPLOYMENT PHASE II: VIRTUALMACHINE SETUP ####
echo "
**** EXPERIMENT DEPLOYMENT PHASE II: VIRTUALMACHINE SETUP ****
"
echo "### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###
$ROBOT_PROTOTYPE_IP" > $PWD/robot/ipSynchronizationTable

echo "### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###
### YOU CAN RUN IT MANUALLY IF NECESSARY ###

#!/bin/bash
" > $PWD/clean/kill_all.sh

NODE_NAME_INDEX=0
for node_name in ${NODE_ALLOCATION_LIST[*]}
do
    echo "ssh $node_name \"kill -9 \\\$(ps -ef | grep ${HOME##*/} | grep -v grep | awk '{print \\\$2}')\"
echo -e \"\\033[31m===> All processes have been killed on $node_name.\\033[0m\"" >> $PWD/clean/kill_all.sh
    
    echo "#!/bin/bash
### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###

RESET_VM=\"$RESET_VM\"

N_ROBOTS_PER_NODE=$N_ROBOTS_PER_NODE
N_VM_MEMS=$N_VM_MEMS
N_VM_CPUS=$N_VM_CPUS

ROBOT_PROTOTYPE_PATH=\"$ROBOT_PROTOTYPE_PATH\"
ROBOT_PROTOTYPE_IP=\"$ROBOT_PROTOTYPE_IP\"
ROBOT_PROTOTYPE_USER=\"$ROBOT_PROTOTYPE_USER\"
ROBOT_PROTOTYPE_PASS=\"$ROBOT_PROTOTYPE_PASS\"

ROBOT_DEPLOYMENT_PATH=\"$ROBOT_DEPLOYMENT_PATH\"
ROBOT_IP_LIST=( ${ROBOT_IP_LIST[@]:$[ $NODE_NAME_INDEX * $N_ROBOTS_PER_NODE ]:$N_ROBOTS_PER_NODE} )

SCRIPT_HOME=$PWD" > vm_setup_header.sh
    
    echo -n "===> Generating file \"vm_setup_$node_name.sh\" ...... "
    cat vm_setup_header.sh vm_setup_main.sh > $PWD/robot/vm_setup_$node_name.sh
    rm vm_setup_header.sh
    chmod a+x $PWD/robot/vm_setup_$node_name.sh
    echo "done!"
    
    ssh $node_name "[ -d $ROBOT_DEPLOYMENT_PATH ] || mkdir -p $ROBOT_DEPLOYMENT_PATH"
    scp $PWD/log_robot_performance.sh $PWD/robot/vm_setup_$node_name.sh $node_name:$ROBOT_DEPLOYMENT_PATH
    [ -f $PWD/log/vm_setup_$node_name.log ] && rm log/vm_setup_$node_name.log # Important! To avoid synchronization error for VM_SETUP_FAILS/VM_SETUP_COMPLETED test.
    ssh -f $node_name "$SHELL $ROBOT_DEPLOYMENT_PATH/vm_setup_$node_name.sh > $PWD/log/vm_setup_$node_name.log 2>&1"
    echo "===> Deploying robot(s) on $node_name ......"
    
    NODE_NAME_INDEX=$(( NODE_NAME_INDEX + 1 ))
done
echo -e "\033[34mYou can check the log files in $PWD/log any time to know the deployment process.\033[0m"

### This test is not robust, but I currently can not find a better way. ###
for node_name in ${NODE_ALLOCATION_LIST[*]}
do
    while [ 1 ]
    do
	if [ -f $PWD/log/vm_setup_$node_name.log ]
	then
	    case $(tail -1 $PWD/log/vm_setup_$node_name.log) in
		VM_SETUP_FAILS)
		    echo "ERROR: robot(s) deployment is failed on $node_name."
		    $SHELL $PWD/clean/kill_all.sh
		    exit $ERROR_VM_SETUP_FAILS
		    ;;
		VM_SETUP_COMPLETED)
		    echo "===> Robot(s) deployment is completed on $node_name."
		    break
		    ;;
	    esac
	fi
	sleep 3
    done
done
##############################################################

###################### START EXPERIMENT ######################
echo "
********************** START EXPERIMENT **********************
"
BOOTED_ROBOTS=0
READY_ROBOTS_TABLE=()
PING_TIMER=0
PING_TIMEOUT=60
FAILED_ROBOTS=0
MAX_FAILED_ROBOTS=0

for n_robots in $(seq $N_ROBOTS_MIN $N_ROBOTS_MAX)
do
    for trial_id in $(seq 1 $N_TRIALS_PTS)
    do
	echo "===> $n_robots robots | test $trial_id <==="
### The following codes are not indented for ease reading! ###
############ CREATE A SIMULATION DESCRIPTION FILE ############
echo -n "===> Creating file \"$SIM_ENV_NAME.py\" ...... "
echo "from morse.builder import *
### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###" > $PWD/morse/$SIM_ENV_NAME.py
for i in $(seq 0 $[ $n_robots - 1 ])
do
    set_robot_init_pose $i
    echo "
################ ROBOT -- $i ###############
p3dx$i = Pioneer3DX()
p3dx$i.add_default_interface('ros')
p3dx$i.translate(x=$ROBOT_INIT_POSE_X, y=$ROBOT_INIT_POSE_Y, z=$ROBOT_INIT_POSE_Z)

odom$i = Odometry()
odom$i.add_interface('ros', frame_id='/p3dx"$i"_tf/odom', child_frame_id='/p3dx"$i"_tf/base_footprint')" >> $PWD/morse/$SIM_ENV_NAME.py
    [ $ODOMETRY_NOISE == "true" ] && echo "odom$i.alter('Noise', pos_std=0.022, rot_std=0.02)" >> $PWD/morse/$SIM_ENV_NAME.py
    echo "odom$i.frequency(10)
p3dx$i.append(odom$i)

sick$i = Sick()
sick$i.translate(z=0.252)
sick$i.properties(Visible_arc=True)
sick$i.properties(scan_window=190)
sick$i.properties(laser_range=26.0)
sick$i.add_interface('ros', frame_id='/p3dx"$i"_tf/base_laser_link')
sick$i.frequency(25)
p3dx$i.append(sick$i)

motion$i = MotionVWDiff()
motion$i.add_interface('ros')
p3dx$i.append(motion$i)" >> $PWD/morse/$SIM_ENV_NAME.py
done
echo "
################ ENVIRONMENT ###############
env = Environment('$MORSE_FILE_PATH/$SIM_ENV_NAME', fastmode=False)
env.place_camera([0, 0, 60])
env.aim_camera([0, 0, 0])" >> $PWD/morse/$SIM_ENV_NAME.py
echo "done!"
##############################################################

############## CREATE A SCRIPT TO LAUNCH MORSE ###############
echo -n "===> Creating file \"$SIM_ENV_NAME.sh\" ...... "
echo "#!/bin/bash
### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###

export ROS_HOSTNAME=$MORSE_HOST
export ROS_MASTER_URI=http://$MORSE_HOST:11311

mkdir -p $MONITOR_LOG_PATH

rm -rf ~/.ros/log

PARAMS=()
PARAMS+=( --tab -e \"bash -c 'roscore;exec bash'\" )
PARAMS+=( --tab -e \"bash -c 'morse run -g 768x768 $SIM_ENV_NAME.py;exec bash'\" )
PARAMS+=( --tab -e \"bash -c 'sleep 3;rosrun tf_splitter tf_splitter;exec bash'\" )
PARAMS+=( --tab -e \"bash -c 'sleep 3;rosrun $MONITOR_PKG_NAME $MONITOR_PKG_NAME _number_robots:=$n_robots _static_map_file:=$MORSE_FILE_PATH/$SIM_ENV_NAME.pgm _dynamic_map_node:=zexploration _explore_cost_node:=zexploration _result_file_path:=$MONITOR_LOG_PATH/${n_robots}robots_test${trial_id}.csv _supervision_rate:=5.0 _explored_match_size:=0.99 _running_timeout:=2000;nc -w 0 $(hostname --ip-address) $MONITOR_LISTEN_PORT;exit;exec bash'\" )
gnome-terminal --working-directory=$MORSE_FILE_PATH \"\${PARAMS[@]}\"" > $PWD/morse/$SIM_ENV_NAME.sh
chmod a+x $PWD/morse/$SIM_ENV_NAME.sh
echo "done!"
##############################################################

################### START MORSE SIMULATOR ####################
echo "#!/bin/bash
### THIS FILE IS AUTOMATICALLY GENERATED BY $0 ###
### YOU CAN RUN IT MANUALLY IF NECESSARY ###

ssh $MORSE_USER@$MORSE_HOST \"kill -9 \\\$(ps -ef | grep morse | grep -v gnome-terminal | grep -v grep | awk '{print \\\$2}')\"
echo -e \"\\033[31m===> MORSE has been shutdown on \\\"$MORSE_HOST\\\".\\033[0m\"
ssh $MORSE_USER@$MORSE_HOST \"kill -9 \\\$(ps -ef | grep ros | grep -v gnome-terminal | grep -v grep | awk '{print \\\$2}')\"
echo -e \"\\033[31m===> ROS has been shutdown on \\\"$MORSE_HOST\\\".\\033[0m\"
sleep 3" > $PWD/clean/kill_run.sh

scp $PWD/morse/$SIM_ENV_NAME.* $MORSE_USER@$MORSE_HOST:$MORSE_FILE_PATH
echo "===> Simulation files have been copied to \"$MORSE_USER@$MORSE_HOST:$MORSE_FILE_PATH\"."
ssh -f $MORSE_USER@$MORSE_HOST "DISPLAY=:0 $MORSE_FILE_PATH/$SIM_ENV_NAME.sh"
echo "===> MORSE has been launched on \"$MORSE_HOST\"."
echo "===> Monitor has been launched on \"$MORSE_HOST\"."
##############################################################

####################### START ROBOT(S) #######################
BOOTED_ROBOTS=0
for node_name in ${NODE_ALLOCATION_LIST[*]}
do
    for i in $(seq 0 $[ $N_ROBOTS_PER_NODE - 1 ])
    do
	echo "
echo -ne \"\\033[31m===> robot_${node_name}_$i OFF \\033[0m\"
ssh $node_name \"export VBOX_USER_HOME=$ROBOT_DEPLOYMENT_PATH/vm; vboxmanage controlvm robot_${node_name}_$i poweroff\"" >> $PWD/clean/kill_run.sh
	
	ssh $node_name "export VBOX_USER_HOME=$ROBOT_DEPLOYMENT_PATH/vm; vboxmanage startvm robot_${node_name}_$i --type headless"
	BOOTED_ROBOTS=$(( BOOTED_ROBOTS + 1 ))
	[ $BOOTED_ROBOTS -ge $n_robots ] && break
    done
    [ $BOOTED_ROBOTS -ge $n_robots ] && break
done

unset READY_ROBOTS_TABLE
for i in $(seq 0 $[ $n_robots - 1 ])
do
    PING_TIMER=0
    while [ 1 ]
    do
	if [ $(ping -c 1 -w 1 ${ROBOT_IP_LIST[$i]} &>/dev/null;echo $?) -ne 0 ]
	then
	    sleep 1
	    PING_TIMER=$(( PING_TIMER + 1 ))
	    echo "Robot ${ROBOT_IP_LIST[$i]} does not respond for $PING_TIMER seconds."
	    if [ $PING_TIMER -ge $PING_TIMEOUT ]
	    then
		READY_ROBOTS_TABLE+=( "false" )
		echo "ERROR: robot ${ROBOT_IP_LIST[$i]} does not respond within $PING_TIMER seconds."
		echo "WARNING: the experiment will start without robot ${ROBOT_IP_LIST[$i]}."
		break
	    fi
	else
	    READY_ROBOTS_TABLE+=( "true" )
	    echo "===> Robot ${ROBOT_IP_LIST[$i]} is ready."
	    break
	fi
    done
done

FAILED_ROBOTS=0
for i in $(seq 0 $[ $n_robots - 1 ])
do
    set_robot_init_pose $i
    if [ ${READY_ROBOTS_TABLE[i]} == "true" ]
    then
	ssh -f $ROBOT_PROTOTYPE_USER@${ROBOT_IP_LIST[$i]} "rm -rf /home/viki/.ros/log; /media/sf_scratch/${HOME##*/}/log_robot_performance.sh $n_robots $trial_id $i ${HOME##*/}; roslaunch /home/viki/Desktop/car_mrs_explore/launch/pioneer3dx.launch i:=$i x:=$ROBOT_INIT_POSE_X y:=$ROBOT_INIT_POSE_Y z:=$ROBOT_INIT_POSE_Z" > /dev/null 2>&1
	echo "===> Robot ${ROBOT_IP_LIST[$i]} has been launched at ($ROBOT_INIT_POSE_X, $ROBOT_INIT_POSE_Y, $ROBOT_INIT_POSE_Z)."
    else
	echo "===> Robot ${ROBOT_IP_LIST[$i]} can not be launched."
	FAILED_ROBOTS=$(( FAILED_ROBOTS + 1 ))
	if [ $FAILED_ROBOTS -gt $MAX_FAILED_ROBOTS ]
	then
	    echo -e "\033[31mERROR: failed robots exceeds the maximum number $MAX_FAILED_ROBOTS.\033[0m"
	    echo -e "\032[31mSOLUTION: please check the virtual machine is set up correctly.\033[0m"
	    #exit $ERROR_MAX_FAILED_ROBOTS # patch20140916
	    ERROR_MAX_FAILED_ROBOTS=0 # patch20140916
	    
	fi
    fi
done
##############################################################

################### END RUN & CLEANING UP ####################
if [ $ERROR_MAX_FAILED_ROBOTS -ne 0 ] # patch20140916
then # patch20140916
    echo -n "===> Waiting for END RUN signal from the monitor $MORSE_HOST ...... "
    nc -d -l $MONITOR_LISTEN_PORT
    echo "roger!"
fi # patch20140916
$SHELL $PWD/clean/kill_run.sh
###### The following lines handle the fucking bug "ssh -f" (not been solved) ######
#for node_name in ${NODE_ALLOCATION_LIST[*]}
#do
#    ssh $node_name "kill -9 \$(ps -ef | grep \"ssh -f\" | awk '{print \$2}')"
#done
###### The following lines handle the fucking bug "VM shutdown blocked" (not been solved) ######
#for node_name in ${NODE_ALLOCATION_LIST[*]}
#do
#    ssh $node_name "kill -9 \$(ps -ef | grep \"VBoxXPCOMIPCD\" | awk '{print \$2}')"
#    ssh $node_name "kill -9 \$(ps -ef | grep \"VBoxSVC --auto-shutdown\" | awk '{print \$2}')"
#done
##############################################################
#################### end for not indented ####################
    done
    [ $ERROR_MAX_FAILED_ROBOTS -eq 0 ] && break # patch20140916
done
##############################################################

################## GET EXPERIMENTAL RESULTS ##################
EXPERIMENTAL_RESULTS_PATH=$(dirname $(pwd))/${HOME##*/}_$(date '+%Y%m%d_%H%M')
mkdir -p $EXPERIMENTAL_RESULTS_PATH/system_metric
mkdir -p $EXPERIMENTAL_RESULTS_PATH/robot_metric

scp $MORSE_USER@$MORSE_HOST:$MONITOR_LOG_PATH/* $EXPERIMENTAL_RESULTS_PATH/system_metric
ssh $MORSE_USER@$MORSE_HOST "rm -rf $MONITOR_LOG_PATH"

for node_name in ${NODE_ALLOCATION_LIST[*]}
do
    scp $node_name:$ROBOT_DEPLOYMENT_PATH/log/* $EXPERIMENTAL_RESULTS_PATH/robot_metric
    ssh $node_name "rm -rf $ROBOT_DEPLOYMENT_PATH/log"
done

echo "===> Experimental results are stored in $EXPERIMENTAL_RESULTS_PATH."
##############################################################

echo "
##############################################################
#           Script has been successfully executed!           #
#  Zhi Yan, Luc Fabresse, Jannik Laval, and Noury Bouraqadi  #
#                       Copyright 2014                       #
##############################################################
"
