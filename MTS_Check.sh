#!/bin/bash

STATUS_DIR="MTS_Folder"         # Directory of tasks status

get_task_count() {
    local state=$1
    ls ${STATUS_DIR}/${state} | wc -l
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
generate_report
