#SBATCH -A Your_Slurm_Account
#SBATCH -J MTS_Run
#SBATCH -o res_MTS_%j.txt
#SBATCH -e err_MTS_%j.txt
#SBATCH -p batch
#SBATCH -N 2048
#SBATCH -t 01:20:00
#SBATCH -C nvme

# ----------------------------------------
# ------- Load Environment
# source /ccs/home/yuanzhuo/Source_Frontier.sh
# export CRAY_CPU_TARGET=x86-64
#----------------------------------------

# ------------------------------------------------------------------ #
# ------------------------ MTS Setups & Run ------------------------ #
# ------------------------------------------------------------------ #
export MTS_MAX_CONCURRENT=2             # Max parallel running tasks number
export MTS_NODES_PER_TASK=2             # Number of nodes per task
export MTS_THREAD_PER_Node=16           # Number of threads on each node 
export MTS_NTASK_PER_GPU=4              # ntask per gpu if you need NGPU_PER_TASK, please contact Yuanzhuo 
export MTS_MPI_PER_TASK=$(($MTS_NODES_PER_TASK * $MTS_THREAD_PER_Node))


# ---------- Run example on Andes (CPU)
#cmd="srun \$MTS_NODES_PER_TASK --nodelist=\${MTS_NodesList%,} -n\$MTS_MPI_PER_TASK ./\${MTS_cmd} > ./result.txt"

# ---------- Run example on Frontier (GPU)
# cmd="srun --nodes=\$MTS_NODES_PER_TASK --nodelist=\${MTS_NodesList%,} -n\$MTS_MPI_PER_TASK -c1 --cpu-bind=threads --threads-per-core=1 -m block:cyclic --ntasks-per-gpu=\$MTS_NTASK_PER_GPU --gpu-bind=closest ./\${MTS_cmd} > ./result.txt"

# ---------- Run example test (Shell)
cmd="sh ./\${MTS_cmd}"

# ----------  For check, output your command
# export MTS_EXE_COMMAND="echo \"$cmd\" "

# ---------- For Real Run
export MTS_EXE_COMMAND="$cmd"

# ------------------------------ MTS RUN -------------------------- #
./MTS_Run.sh
# ----------------------------------------------------------------- #



