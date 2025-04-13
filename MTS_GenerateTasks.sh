#!/bin/bash
###
 # @Author: Yuanzhuo Ma
 # @Date: 2025-03-23 23:51:59
 # @LastEditors: Yuanzhuo Ma
 # @LastEditTime: 2025-04-12 22:12:58
 # @FilePath: /Slurm_scheduler/ver1_20250412/MTS_GenerateTasks.sh
 # @Description: 
 # 
### 

# --- Generate Tasks lists

# for i in {14..38}; do
rm MTS_Task.task
Path=$(pwd)
ind_tot=0

Path_2="/"
MTS_cmd="run_test.sh"

# ------- for Lt200
index=1
for ((i=1; i<=6; i+=1)); do
    ((ind_tot++))
    echo $ind_tot"|"$Path"/Test_task/run_${index}${Path_2}|${MTS_cmd} "
    echo $ind_tot"|"$Path"/Test_task/run_${index}${Path_2}|${MTS_cmd} " >> MTS_Task.task
    index=$(($index + 1))
done

