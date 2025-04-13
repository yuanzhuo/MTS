# **MTS (Multi-Task Scheduler)**  

**MTS** is a lightweight bash-based task scheduler designed to distribute and manage multiple tasks efficiently using HPC resources (CPU/GPU) allocated through **a single Slurm job**. Inspired by [MTEAQ](https://github.com/evanberkowitz/metaq), MTS simplifies task management by leveraging a file-based system to track job status. It is **easy to set up** and can run any language code (like C++, Fortran, Python etc.) with MTS and it can also be used on local machines (e.g., laptops).  

---

## **User Guide**  

### **Overview**  
1. **Clone the repository**:  
   ```bash
   git clone https://github.com/your-repo/MTS.git
   cd MTS
   ```  
2. **Grant execute permissions**:  
   ```bash
   chmod +x *.sh
   ```  
3. **Generate tasks**:  
   Modify `MTS_GenerateTasks.sh` and run it to create task definitions:  
   ```bash
   ./MTS_GenerateTasks.sh
   ```  
4. **Initialize MTS**:  
   ```bash
   ./MTS_Initial.sh
   ```  
5. **Configure Slurm**:  
   Edit `slurm_Run.sh` to match your HPC system’s requirements.  
6. **Submit the job**:  
   ```bash
   sbatch slurm_Run.sh
   ```  
7. **Monitor progress**:  
   ```bash
   ./MTS_Check.sh
   ```  

---

### **Advanced Configuration**  

#### **Task File Format**  
`MTS_GenerateTasks.sh` generates `MTS_Tasks.task` with the following structure:  
```plaintext
task_# | task_path | task_executable_name
```  
You may edit this file manually if needed.  

#### **Check Mode**  
To validate paths without execution, uncomment this line in `slurm_Run.sh`:  
```bash
export MTS_EXE_COMMAND="echo \"$cmd\""
```  

#### **Key Environment Variables**  
Configure these in `slurm_Run.sh`:  
- `MTS_MAX_CONCURRENT`: Maximum parallel tasks.  
- `MTS_NODES_PER_TASK`: Nodes allocated per task.  
- `MTS_THREADS_PER_NODE`: Threads per node.  
- `MTS_NTASK_PER_GPU`: Tasks per GPU (or `NGPU_PER_TASK` for GPU count).  
- `cmd`: The actual Slurm command executed for each task.  

---

### **Support**  
For questions or issues, please find contact [here](https://yuanzhuo.github.io/)  
