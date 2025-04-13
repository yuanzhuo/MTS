#!/bin/bash
###
 # @Author: Yuanzhuo Ma
 # @Date: 2025-03-15 11:01:31
 # @LastEditors: Yuanzhuo Ma
 # @LastEditTime: 2025-04-12 22:10:40
 # @FilePath: /Slurm_scheduler/ver1_20250412/MTS_Initial.sh
 # @Description: 
 # 
### 

# ------ Multi-Task Scheduler
TASK_LIST="MTS_Task.task"       # Original Task list
STATUS_DIR="MTS_Folder"         # Directory of tasks status
LOCK_FILE=".scheduler.lock"      # File locker

echo "Do you want to refresh MTS_Folder? !!  1: yes other: exit"
read input
if [[ ! "$input" == "1" ]]; then
    echo "input: $input and exit"
    exit 0 
fi

init_status_dirs() {
    mkdir -p ${STATUS_DIR}/{pending,running,completed,failed}
    
    rm -f ${STATUS_DIR}/pending/*
    rm -f ${STATUS_DIR}/running/*
    rm -f ${STATUS_DIR}/completed/*
    rm -f ${STATUS_DIR}/failed/*
    
    if [ -f "$TASK_LIST" ]; then
        task_id=1
        while IFS= read -r line; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            echo "$line" > "${STATUS_DIR}/pending/task_${task_id}"
            ((task_id++))
            sleep 0.01
        done < "$TASK_LIST"
    else
        echo "Wrong: $TASK_LIST does not exist"
        exit 1
    fi
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

# --- move file (atomic operation)
move_task() {
    local task_id=$1
    local from=$2
    local to=$3
    mv ${STATUS_DIR}/${from}/${task_id} ${STATUS_DIR}/${to}/ 2>/dev/null
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

echo "===== Start Initial Tasks ====="

init_status_dirs

wait
generate_report 
echo "===== Finished Initial Tasks ====="