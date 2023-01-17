#!/usr/bin/env bash

FILE=$1
source ./00_source.inc

### ENTER SCRIPTS FOLDER AND MERGE SLURM FILES INTO 'SLURM.OUT'
cd $LOC_SCRIPTS/${FILE}
cat slurm* > $LOC_OUT/slurm.out
mkdir -p ${LOC_SCRIPTS}/$FILE/temp_x${N}/
mv slurm* ${LOC_SCRIPTS}/$FILE/temp_x${N}/

# ENTER THE OUTPUT FOLDER
cd $LOC_OUT

mkdir -p $LOC_OUT/JSON
mkdir -p $LOC_OUT/UNRLXD

for i in {1..5}; do                                
  mv model_${i}_*_*_*_*_*.pdb $LOC_OUT/UNRLXD/${FILE}_model_${i}_x${N}.pdb
  [ -f model_${i}_*_*_*_*_*.pkl ]; rm model_${i}_*_*_*_*_*.pkl
  mv relaxed_model_${i}_*   ${FILE}_rlx_model_${i}_x${N}.pdb
  mv ranking_model_${i}_*   $LOC_OUT/JSON/${FILE}_ranking_model_${i}.json
done

[-f checkpoint ] rm -r checkpoint
