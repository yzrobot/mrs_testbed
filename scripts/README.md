*** Version 1.0 (uploaded 25/07/2014) ***
1. Scripts for multi-robot exploration simulation:
   - submit_job.sh
   - start_simulation.sh
   - vm_setup_main.sh

*** Version 1.1 (uploaded 28/08/2014) ***
1. System cleanup tool:
   - clean/remove_all_in_scratch.sh
2. Robot performance logger (cpu, ram, network I/O):
   - log_robot_performance.sh

*** Version 1.1.1 (uploaded 04/09/2014) ***
1. Updated robot prototype checking:
   - cp -rf /lustre/zhi.yan/robot_prototype/ $ROBOT_PROTOTYPE_PATH
2. Solved robot deployment permission problems:
   - ROBOT_DEPLOYMENT_PATH="/scratch/${HOME##*/}"

*** Version 1.1.2 (uploaded 28/09/2014) ***
1. Solved robot SSH authentication problems:
   - "auto_ssh" test before "ssh" in vm_setup_main.sh
 
*** TODO: resolve "VM can't be shutdown properly" in each run *** 