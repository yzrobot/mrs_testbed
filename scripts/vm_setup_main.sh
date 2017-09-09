#!/bin/bash

### Copyright (C) 2014 Zhi Yan

NFS_BUG_TIMER=0
NFS_BUG_TIMEOUT=30

PING_TIMER=0
PING_TIMEOUT=60

VM_SHUTDOWN_TIMER=0
VM_SHUTDOWN_TIMEOUT=30

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

### Reset VM configuration file (VirtualBox.xml) and log files ###
# [ -d vm ] && rm -rf vm
# mkdir vm
### The above 2 lines is the cleanest solution,                ###
### but it raises a fucking synchronization bug:               ###
### rm: cannot remove vm/.nfsXXX: Device or resource busy!     ###
### So we have to do is:                                       ###
if [ -d $ROBOT_DEPLOYMENT_PATH/vm ]
then
    while [ $(rm -rf $ROBOT_DEPLOYMENT_PATH/vm &>/dev/null;echo $?) -ne 0 ]
    do
	sleep 1
	NFS_BUG_TIMER=$(( NFS_BUG_TIMER + 1 ))
	echo ".nfs file(s) can not be removed for $NFS_BUG_TIMER seconds."
	if [ $NFS_BUG_TIMER -ge $NFS_BUG_TIMEOUT ]
	then
	    echo "ERROR: .nfs file(s) can not be removed within $NFS_BUG_TIMER seconds!"
	    { echo "VM_SETUP_FAILS";exit 1; }
	fi
    done
fi
mkdir -p $ROBOT_DEPLOYMENT_PATH/vm
echo "Folder \"$ROBOT_DEPLOYMENT_PATH/vm\" has been cleared."

### Set VBOX environment variables for depositing VirtualBox.xml ###
export VBOX_USER_HOME=$ROBOT_DEPLOYMENT_PATH/vm
echo VBOX_USER_HOME=$VBOX_USER_HOME

### Copy and register robot prototype ###
if [[ $RESET_VM == "true" || ! -d $ROBOT_DEPLOYMENT_PATH/robot_prototype ]]
then
    cp -r $ROBOT_PROTOTYPE_PATH $ROBOT_DEPLOYMENT_PATH
    echo "robot_prototype has been copied from $ROBOT_PROTOTYPE_PATH to $ROBOT_DEPLOYMENT_PATH."
fi
vboxmanage registervm $ROBOT_DEPLOYMENT_PATH/robot_prototype/robot_prototype.vbox || { echo "VM_SETUP_FAILS";exit 1; }

### Clone and register robots (VMs) ###
for i in $(seq 0 $[ ${#ROBOT_IP_LIST[@]} - 1 ])
do
    ### For safety and also avoiding bugs, we always clone VMs. It does not take long time. ###
    #if [[ $RESET_VM == "true" || ! -d $ROBOT_DEPLOYMENT_PATH/robot_${HOSTNAME%%.*}_$i ]]
    #then
    #vboxmanage clonevm robot_prototype --name robot_${HOSTNAME%%.*}_$i --basefolder $ROBOT_DEPLOYMENT_PATH
    #fi
    #vboxmanage registervm $ROBOT_DEPLOYMENT_PATH/robot_${HOSTNAME%%.*}_$i/robot_${HOSTNAME%%.*}_$i.vbox
    [ -d $ROBOT_DEPLOYMENT_PATH/robot_${HOSTNAME%%.*}_$i ] && rm -rf $ROBOT_DEPLOYMENT_PATH/robot_${HOSTNAME%%.*}_$i
    vboxmanage clonevm robot_prototype --name robot_${HOSTNAME%%.*}_$i --basefolder $ROBOT_DEPLOYMENT_PATH --register || { echo "VM_SETUP_FAILS";exit 1; }
done

### Modify robots' IP address ###
LAST_ASSIGNED_IP_ADDRESS=$(tail -1 $SCRIPT_HOME/robot/ipSynchronizationTable)
for i in $(seq 0 $[ ${#ROBOT_IP_LIST[@]} - 1 ])
do
    echo -e "\n**************** robot_${HOSTNAME%%.*}_$i ****************\n"
    
    ### Avoid to simultaneously modify multiple ROBOT_PROTOTYPE_IPs causing conflict ###
    echo -n "Waiting for IP address assignment ${ROBOT_IP_LIST[$i]} ...... "
    while [ $[ ${LAST_ASSIGNED_IP_ADDRESS##*.} + 1 ] -ne ${ROBOT_IP_LIST[$i]##*.} ]
    do
	sleep 1
	LAST_ASSIGNED_IP_ADDRESS=$(tail -1 $SCRIPT_HOME/robot/ipSynchronizationTable)
    done
    echo "ok!"
    
    ### Start the virtual machine (robot) ###
    vboxmanage startvm robot_${HOSTNAME%%.*}_$i --type headless || { echo "VM_SETUP_FAILS";exit 1; }
    
    ### Make sure the VM has been started within the prescribed time ###
    PING_TIMER=0
    while [ $(ping -c 1 -w 1 $ROBOT_PROTOTYPE_IP &>/dev/null;echo $?) -ne 0 ]
    do
	sleep 1
	PING_TIMER=$(( PING_TIMER + 1 ))
	echo "robot_${HOSTNAME%%.*}_$i does not respond for $PING_TIMER seconds."
	if [ $PING_TIMER -ge $PING_TIMEOUT ]
	then
	    echo "ERROR: robot_${HOSTNAME%%.*}_$i does not respond within $PING_TIMER seconds, force shutdown:"
	    vboxmanage controlvm robot_${HOSTNAME%%.*}_$i poweroff
	    { echo "VM_SETUP_FAILS";exit 1; }
	fi
    done
    
    ### (28/09/2014) This part should be tested and validated by Luc ###
    auto_ssh $ROBOT_PROTOTYPE_PASS $ROBOT_PROTOTYPE_USER@$ROBOT_PROTOTYPE_IP :
    SSH_ERROR_CODE=$?
    if [ $SSH_ERROR_CODE -eq 0 ]
    then
	auto_ssh_copy_id $ROBOT_PROTOTYPE_PASS "-i $HOME/.ssh/id_rsa.pub $ROBOT_PROTOTYPE_USER@$ROBOT_PROTOTYPE_IP"
	[ $? -eq 1 ] && { echo "VM_SETUP_FAILS";exit 1; }
    fi
    [ $SSH_ERROR_CODE -gt 1 ] && { echo "VM_SETUP_FAILS";exit 1; }
    echo "===> SSH authentication is ok!"
    ### (28/09/2014) end of part ###
    
    ### Modify the virtual machine IP address ###
    echo "robot_${HOSTNAME%%.*}_$i is ready."
    ### IF the route for CHAPO is changed, DO ###
    # ssh $ROBOT_PROTOTYPE_USER@$ROBOT_PROTOTYPE_IP "echo -e \"\nauto eth0\niface eth0 inet static\naddress ${ROBOT_IP_LIST[$i]}\nnetmask 255.255.0.0\ngateway 10.3.0.1\ndns-nameservers 10.3.11.1\npost-up route add -net 10.1.0.0 netmask 255.255.0.0 gw 10.3.11.1\n\" | sudo tee -a /etc/network/interfaces; sudo shutdown -h now"
    ### IF NOT ###
    ssh $ROBOT_PROTOTYPE_USER@$ROBOT_PROTOTYPE_IP 'echo -e \"\nauto eth0\niface eth0 inet static\naddress ${ROBOT_IP_LIST[$i]}\nnetmask 255.255.0.0\ngateway 10.3.0.1\ndns-nameservers 10.3.11.1\n\" | sudo tee -a /etc/network/interfaces; sudo shutdown -h now'
    ### END IF ###
    echo "robot_${HOSTNAME%%.*}_$i was set a new IP address: ${ROBOT_IP_LIST[$i]}."
    
    ### The following lines handle the fucking bug "VM can not be shutdown properly"  ###
    VM_SHUTDOWN_TIMER=0
    while [[ $(vboxmanage showvminfo robot_${HOSTNAME%%.*}_$i | grep "State") == *running* ]]
    do
	sleep 1
	VM_SHUTDOWN_TIMER=$(( VM_SHUTDOWN_TIMER + 1 ))
	echo "robot_${HOSTNAME%%.*}_$i does not shutdown for $VM_SHUTDOWN_TIMER seconds."
	if [ $VM_SHUTDOWN_TIMER -ge $VM_SHUTDOWN_TIMEOUT ]
	then
	    echo "robot_${HOSTNAME%%.*}_$i does not shutdown within $VM_SHUTDOWN_TIMER seconds, force shutdown:"
	    vboxmanage controlvm robot_${HOSTNAME%%.*}_$i poweroff || { echo "VM_SETUP_FAILS";exit 1; }
	fi
    done
    echo "robot_${HOSTNAME%%.*}_$i has been shutdown."
    echo "${ROBOT_IP_LIST[$i]}" >> $SCRIPT_HOME/robot/ipSynchronizationTable
    
    ### Setup the memory size (MB) and the number of CPUs for VM ###
    sleep 3 # sleep for avoiding the fucking VBoxManage error: The machine is already locked for a session (or being unlocked)
    vboxmanage modifyvm robot_${HOSTNAME%%.*}_$i --memory $N_VM_MEMS --cpus $N_VM_CPUS || { echo "VM_SETUP_FAILS";exit 1; }
    echo "robot_${HOSTNAME%%.*}_$i memory = $N_VM_MEMS, cpus = $N_VM_CPUS."
done

echo "VM_SETUP_COMPLETED"
