# MTS (Multi-Task Scheduler) 
MTS is a bash-level scheduler, which can be used to distribute and run a bunch of tasks with HPC CPU (and/or GPU) resources allocated by OLNLY ONE Slurm run. 
It was inspired by [MTEAQ](https://github.com/evanberkowitz/metaq), which uses folders and files to identify and detect job status. MTS is easly to setup and can be also used on laptop. 

## User Guide
### General work flow
- git clone this repository to your local device or HPC folder
- Add "-x" authority to all the *.sh files, like `chmod -x *.sh`
- Modify "MTS_GenerateTasks.sh" and generate task path and exec names by `./MTS_GenerateTasks.sh`
- Run "MTS_Initial.sh" to initialize the MTS_folder, by `./MTS_Initial.sh`
- Modify "slurm_Run.sh" according to your own systems
- Submit slurm command by `sbatch slurm_Run.sh`
- Check job running status by `./MTS_Check.sh`

### More about MTS 
- "MTS_GenerateTasks.sh" will generate a file "MTS_Tasks.task". The task format is "task_# | task_path | task_executive_name". One can also modify "MTS_Tasks.task" manually.
- "Check_Mode": If one want to check if all the path is okay, one can uncommant `export MTS_EXE_COMMAND="echo \"$cmd\" `
 
