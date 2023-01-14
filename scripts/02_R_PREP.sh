#!/usr/bin/env bash

FILE=$1
source ./00_source.inc

### ENTER SCRIPTS FOLDER AND MERGE SLURM FILES INTO 'SLURM.OUT'
cd $LOC_SCRIPTS/${FILE}
cat slurm* > $LOC_OUT/slurm.out
mkdir -p ${LOC_SCRIPTS}/$FILE/temp/
mv slurm* ${LOC_SCRIPTS}/$FILE/temp/
#rm slurm*  # to stop accumulation of slurm files for future runs

# ENTER THE OUTPUT FOLDER
cd $LOC_OUT

# RENAME FILES (PKL FILES ARE MOVED TO A JOINED PKL FOLDER)
for i in {1..5}; do
  mv model_${i}_*_*_*_*.pdb ${FILE}_model_${i}_x${N}.pdb
  rm model_${i}_*_*_*_*.pkl
  mv relaxed_model_${i}_*   ${FILE}_rlx_model_${i}_x${N}.pdb
  mv ranking_model_${i}_*   ${FILE}_ranking_model_${i}.json
done

rm -r checkpoint
