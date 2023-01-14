# fluffyAlpaca
A pipeline designed to simultaneously process multiple samples from FASTA to multimeric models based on AlphaFold algorithms (AF Multimer) and AF2C scripts optimized for complex prediction. Scripts are written to work on the HPC RAVEN cluster (MPCDF) using SLURM as the workload manager.

### 1. Clone the git repository into your workplace (In your home directory)

```
git clone https://github.com/FreshAirTonight/af2complex
git clone https://github.com/tlobnow/fluffyAlpaca.git
```

### 2. Prepare the environment

```
pip uninstall -y tensorflow
cd af2complex && pip install -r requirements.txt
pip install --upgrade jax==0.2.14 jaxlib==0.1.69+cuda111 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
```

### 3. Add your fasta files in *fasta_files*

OPTIONS:

1. Create a new folder with your FASTA files in **fasta_files**. File names should end with *EXAMPLE.fasta* (see example in folder). Folders can be created with:
  
  ```
  mkdir FOLDER_NAME
  ```

2. If you start with a combined fasta file (multiple sequences in one file), you can **split** your files using a neat little function called *splitfasta*. This will automatically create a folder named *EXAMPLE_split_files* and store the new files as *EXAMPLE_{1..X}.fasta*, so it will **not** extract the FASTA description ...

  Can be installed with:

  ```
  pip install splitfasta
  ```
  
  Usage:

  ```
  splitfasta EXAMPLE.fasta
  ```

### 4. Adjust 00_source.inc in *scripts*

1. Adjust **MODEL** to "yes" (default = "no")
2. Adjust **FOLDER** to your FASTA folder (default = GFP)
3. Adjust the stoichiometry with **N** (number of monomers) (default = 6, so a homohexamer)

  - of course you can also create more complex multimers, see details in 00_source.inc

### 5. Start the pipeline

Enter **fluffyAlpaca/scripts** to start the pipeline.

If you run this script **ONCE**, you will run MSA and model prediction, unless RAVEN crosses your plans, the relaxation should also finish. Run again, if you're unsure. The pipeline will automatically determine the current progress status and start the necessary scripts.
Run this script **AGAIN** to ensure that all processes have finished and to prepare the output files for analysis in R.

```
./runMe.sh
```

You can check your slurm job status with `./squeue_check.sh` or manually via `squeue -u $USER`

Slurm jobs can be cancelled with: `scancel $JOBID`
ALL currently running jobs can be cancelled with: `scancel -u $USER`

### Folder Structure Main

  - *fasta_files*: where fasta files are stored
  - *feature_files*: output from the MSA lands here (msa folder + **.pkl** file)
  - *output_files*:  where modeling results are stored
  - *scripts*: everything you need to run the pipeline

#### Folder Structure fasta_files

  - set up folders that contain the FASTA files you want to model
  - folder content is used to create a designated folder in scripts
  - all FASTA files will also be copied into the main FASTA folder, once you start pipeline preparations (runMe.sh)

#### Folder Structure feature_files

  - Multiple Sequence Alignment (MSA, performed with script1_msa.sh) produces:
    - features.pkl file - pickle file that functions as input for modeling
    - msa folder - contains some info from the MSA

#### Folder Structure output_files

  - Modeling Scripts (performed with script2_comp_model_{1..5}.sh) produce:
    - model_{1..5}_XXX.pdb
    - model_{1..5}_XXX.pkl
    - ranking_model_{1..5}_XXX.json
    
  - Relaxation Scripts (performed with script3_relaxation.sh) produces:
    - relaxed_model_{1..5}_XXX.pdb

#### Folder Structure scripts

  - 00_source.inc = contains all important variable locations for runME.sh, 01_MODEL.sh, and 02_R_PREP.sh
  - 01_MODEL.sh = pipeline coordinator script. Determines current progress and prompts next scripts
  - 02_R_PREP.sh = manual R prep script (optional for prep of specific output folders)
  - RUNS = folder that contains script folders for all your target runs
  - lists = folder with lists (only individuals in the list corresponding to your target folder)


##### Folder Structure template

This folder is copied for each file. The output slurm files will be stored here.

  - 00_user_parameters.inc  = contains file name, created when pipeline starts
  - 01_user_parameters.inc  = specify variables for script1_msa.sh
  - 02_user_parameters.inc  = -..- script2_comp_model_{1..5}.sh
  - script1_msa.sh          = script for Multiple Sequence alignment
  - script2_comp_model_{1..5}.sh = script for structure prediction with multimer neural network 1-5
  - script3_relaxation.sh   = script for relaxation (getting rid of unphysical clashes) of all models
  - submit_{1-5}.sh         = script to start script2_comp_model_{1..5}.sh as a slurm job
  - submit_big_pipe.sh.     = script that prompts msa + prediction + rlx scripts as consecutive slurm jobs
  - submit_rlx.sh           = script to start script3_relaxation.sh for all models as a slurm job
  - submit_small_pipe.sh    = script that prompts prediction + rlx scripts as consecutive slurm jobs (SKIPS MSA)
  - target.lst              = contains modeling stoichiometry, created when pipeline starts
  
  
