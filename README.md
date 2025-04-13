# MTS (Multi-Task Scheduler) 
MTS is a bash-level scheduler, which can be used to distribute and run a bunch of tasks with HPC CPU (and/or GPU) resources allocated by OLNLY ONE Slurm run. 
It was inspired by [MTEAQ](https://github.com/evanberkowitz/metaq), which uses folders and files to identify and detect job status. MTS is easly to setup and can be also used on laptop. 

## User Guaid
- git clone this repository to your local device or HPC folder
- Add "-x" authority to all the *.sh files, like `chmod -x *.sh`
- Modify "MTS_GenerateTasks.sh" and generate task path and exec names by `./MTS_GenerateTasks.sh`
- Run "MTS_Initial.sh" to initialize the MTS_folder, by `./MTS_Initial.sh`
- Modify "slurm_Run.sh" according to your own systems
- submit slurm command by `sbatch slurm_Run.sh`
 
