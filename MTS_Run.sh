#!/bin/bash

###
 # @Author: Yuanzhuo Ma
 # @Date: 2025-03-27 15:55:52
 # @LastEditors: Yuanzhuo Ma
 # @LastEditTime: 2025-04-12 22:40:33
 # @FilePath: /Slurm_scheduler/ver1_20250412/MTS_Run.sh
 # @Description: 
 # 
### 

TASK_LIST="MTS_Task.task"       # Original Task list
# MTS_MAX_CONCURRENT=32                 # Max parallel running tasks number
# MTS_NODES_PER_TASK=64                 # Number of nodes per task
# MTS_THREAD_PER_Node=16                 # Number of nodes per task
# MTS_MPI_PER_TASK=$(($MTS_NODES_PER_TASK * $MTS_THREAD_PER_Node))
# MTS_NTASK_PER_GPU=4
STATUS_DIR="MTS_Folder"         # Directory of tasks status
LOCK_FILE=".scheduler.lock"      # File locker
TASK_TIME_TOT=3600000
TASK_TIME_LIME_EACH_MIN=600000   

declare -gA SLOT_ALL=()      # 
for ((slot=0; slot<MTS_MAX_CONCURRENT; slot++)); do
        SLOT_ALL[$slot]=$slot
done
echo "=========================================================="
echo "===== Multi Tasks Schedular Start [$(date +'%F %T')] ====="
echo "=========================================================="
echo " "
echo "MTS_MAX_CONCURRENT" $MTS_MAX_CONCURRENT
echo "SLOT_ALL" ${SLOT_ALL[@]}
echo "MTS_NODES_PER_TASK" $MTS_NODES_PER_TASK
echo "MTS_THREAD_PER_Node" $MTS_THREAD_PER_Node
echo "MTS_MPI_PER_TASK" $MTS_MPI_PER_TASK
echo "MTS_NTASK_PER_GPU" $MTS_NTASK_PER_GPU
echo "TASK_TIME_LIME_EACH_MIN" $TASK_TIME_LIME_EACH_MIN


# ------------------------------------------------------------------ #
# ----------------------- Slurm Run Script ------------------------- #
# ------------------------------------------------------------------ #

slurm_run_command() {

    local MTS_NodesList=$1
    local MTS_cmd=$2
    echo "MTS_cmd: " $MTS_cmd
    echo "MTS_EXE_COMMAND: " $MTS_EXE_COMMAND
    eval "$MTS_EXE_COMMAND" 2>&1
    # ---- for Test
    # timeout 10s ./${task_cmd} > ./result.txt 2>&1
}
# ------------------------------------------------------------------ #
# ------------------------------------------------------------------ #



init_node_groups() {
    # ------------------------------
    # --- get all nodes information
    IFS=$'\n' sorted_nodes=($(scontrol show hostnames $SLURM_JOB_NODELIST | sort -V))

    total_nodes=${#sorted_nodes[@]}
    
    # --- group nodes
    declare -gA NODE_GROUPS
    local group_index=0
    for ((i=0; i<total_nodes; i+=MTS_NODES_PER_TASK)); do
        end_index=$((i + MTS_NODES_PER_TASK - 1))
        [ $end_index -ge $total_nodes ] && end_index=$((total_nodes - 1))
        
        # ---- generate node list (node1,node2...)
        group_nodes=$(IFS=,; echo "${sorted_nodes[*]:i:MTS_NODES_PER_TASK}")
        NODE_GROUPS[$group_index]=$group_nodes
        ((group_index++))
    done
    
    # --- output node group details
    echo "---- Group of Node List ----"
    # for gid in "${!NODE_GROUPS[@]}"; do
    for ((gid=0; gid<${#NODE_GROUPS[@]}; gid++)); do
        echo "group $gid: ${NODE_GROUPS[$gid]}"
    done
}


# --- atomic operation (use file lock)
atomic_operation() {
    (
        flock -x 200
        $@
    ) 200>${LOCK_FILE}
}

# --- get tasks status
get_task_count() {
    local state=$1
    ls ${STATUS_DIR}/${state} | wc -l
}

get_empty_slots() {
    local slots_using=()
    local directory=${STATUS_DIR}/"running"
    for file in "$directory"/*; do
        local id=$(echo "$file" | sed -n 's/.*_\([0-9]\+\)$/\1/p')
        if [[ -n "$id" ]]; then
            slots_using+=($id)
        fi
    done
    # echo $slots_using
    local slots_empty=()
    for elem in ${SLOT_ALL[@]}; do
        # --- check If element is in slots_using
        if [[ ! " ${slots_using[@]} " =~ " $elem " ]]; then
           slots_empty+=($elem)
        fi
    done
    echo ${slots_empty[@]}
}

# --- move file (atomic operation)
move_task() {
    local task_id=$1
    local from=$2
    local to=$3
    mv ${STATUS_DIR}/${from}/${task_id} ${STATUS_DIR}/${to}/ 2>/dev/null
}

change_taskname() {
    local task_id=$1
    local task_idnew=$2
    local path=$3
    mv ${STATUS_DIR}/${path}/${task_id} ${STATUS_DIR}/${path}/${task_idnew} 2>/dev/null
}

generate_report() {
    echo "===== Report [$(date +'%F %T')] ====="
    echo "Total Task: $(($(get_task_count pending)+$(get_task_count running)+$(get_task_count completed)+$(get_task_count failed)))"
    echo "Pending: $(get_task_count pending)"
    echo "running: $(get_task_count running)"
    echo "finished: $(get_task_count completed)"
    echo "failed: $(get_task_count failed)"
    echo "----------------------------------------"
}

# ---
execute_task() {
    local task_file=$1
    local nodes=$2
    local slot_id=$3
    local task_file_new=$task_file"_slot_"$slot_id
    
    # --- get task info
    IFS='|' read -ra task_info <<< "$(cat ${STATUS_DIR}/pending/${task_file})"
    task_path="${task_info[1]}"
    task_cmd="${task_info[@]:2}"
    
    # --- mark task status (atomic operation)
    atomic_operation move_task $task_file pending running
    change_taskname $task_file $task_file_new running

    sleep 2

    echo " "
    echo "----------------------------------------"
    echo "${task_file}" "${task_info[@]}" "nodes:" $nodes #>> $STATUS_File

    

    Path_MTS=$(pwd)
    # ----- change running DIR
    cd ${task_path}
    echo $(pwd)

    # ---- delete " "
    cmd=$(echo "$task_cmd" | tr -d ' ')
    # echo $cmd

    slurm_run_command "$nodes" "$cmd"
    # wait
    
    ret=$?
    
    echo -e "\n+++ Task " "${task_file}" " Finished at [$(date +'%F %T')]" 

    # ----- change Path to MTS DIR
    cd ${Path_MTS}

    # --- mark task status
    if [ $ret -eq 0 ]; then
        atomic_operation move_task $task_file_new running completed
    else
        atomic_operation move_task $task_file_new running failed
    fi
}


start_time=$(date +%s)

# ------ get Init status -------- #

generate_report

init_node_groups

# ------ Check Empty Slots ------ #
empty_slots_char="$(get_empty_slots)"
IFS=' ' read -r -a empty_slots <<< $empty_slots_char
free_slots=${#empty_slots[@]}
if [[ $free_slots -ne $MTS_MAX_CONCURRENT ]]; then
    echo "free_slots: $free_slots"
    echo "!!! running folder is not Empty !!! Please Run: MTS_Initial.sh"
    exit
fi 
echo "free_slots: $free_slots"

echo "---- Start MTS Main Loop ----"
check_running_flag=1
while (( $(date +%s) - start_time < $TASK_TIME_TOT )); do
    

    # --- check task slots
    # --- read char to array
    empty_slots_char="$(get_empty_slots)"
    IFS=' ' read -r -a empty_slots <<< $empty_slots_char
    free_slots=${#empty_slots[@]}

    # echo "empty_slots" ${empty_slots[@]}

    # --- distribute tasks
    for (( i=0; i<free_slots; i++ )); do
        # --- Get Next Task
        # --- ls -tr  according modified time; ls -v according name
        # next_task=$(ls -tr ${STATUS_DIR}/pending/ 2>/dev/null | head -1)
        next_task=$(ls -v ${STATUS_DIR}/pending/ 2>/dev/null | head -1)
        [ -z "$next_task" ] && break
        
        # --- get node list
        slot_id=${empty_slots[$i]}
        # echo "slot_id" $slot_id
        nodes=${NODE_GROUPS[$slot_id]}

        # nodes="TestNode1 "$next_task
        # --- run tasks
        execute_task "$next_task" "$nodes" "$slot_id" & 

        sleep 3
    done
    
    sleep 3

    running_tasks=$(get_task_count running) 
    pending_tasks=$(get_task_count pending)

    if [[ $running_tasks -eq 0  &&  $pending_tasks -eq 0 ]]; then
        echo "No task is running; check: " $check_running_flag
        check_running_flag=$((${check_running_flag}+1))
        sleep 1
        if [ $check_running_flag -ge 11 ]; then
            break
        fi
    fi
    
    # --- Check Running Tasks, whether running time longer than TASK_TIME_LIME_EACH_MIN
    # echo "Check running file time"
    if [[ $running_tasks -gt 0 ]]; then
        find ${STATUS_DIR}/running/* -mmin +"$TASK_TIME_LIME_EACH_MIN" -exec mv {} ${STATUS_DIR}/failed/ \;
    fi
done

wait
wait
generate_report
echo "===== ALL TASKS FINSHED ====="